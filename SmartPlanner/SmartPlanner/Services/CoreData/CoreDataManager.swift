//
//  CoreDataManager.swift
//  SmartPlanner
//
//  Created by HS_Jack_YZY on 2024/12/11.
//

import CoreData
import Foundation

/// CoreData 管理类，负责处理所有 CoreData 相关操作
final class CoreDataManager {
    /// 单例实例
    static let shared = CoreDataManager()
    
    /// 持久化容器
    private let container: NSPersistentContainer
    
    /// 主线程上下文
    var mainContext: NSManagedObjectContext {
        container.viewContext
    }
    
    /// 私有初始化方法
    private init() {
        container = NSPersistentContainer(name: "SmartPlanner")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("CoreData 加载失败: \(error.localizedDescription)")
            }
        }
        
        // 配置主上下文
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    /// 创建后台上下文
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    /// 保存上下文
    /// - Parameter context: 需要保存的上下文
    /// - Throws: CoreData 保存错误
    func saveContext(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    /// 在后台执行任务
    /// - Parameter operation: 要执行的操作
    func performBackgroundTask(_ operation: @escaping (NSManagedObjectContext) throws -> Void) {
        let context = newBackgroundContext()
        context.performAndWait {
            do {
                try operation(context)
                try saveContext(context)
            } catch {
                print("后台任务执行失败: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - CRUD Operations
extension CoreDataManager {
    /// 创建实体
    /// - Parameters:
    ///   - entityType: 实体类型
    ///   - context: 上下文
    /// - Returns: 创建的实体实例
    func create<T: NSManagedObject>(_ entityType: T.Type, context: NSManagedObjectContext) -> T {
        T(context: context)
    }
    
    /// 获取实体
    /// - Parameters:
    ///   - entityType: 实体类型
    ///   - predicate: 查���条件
    ///   - context: 上下文
    /// - Returns: 查询结果
    func fetch<T: NSManagedObject>(_ entityType: T.Type,
                                  predicate: NSPredicate? = nil,
                                  sortDescriptors: [NSSortDescriptor]? = nil,
                                  context: NSManagedObjectContext) throws -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: entityType))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return try context.fetch(request)
    }
    
    /// 更新实体
    /// - Parameters:
    ///   - object: 要更新的实体
    ///   - context: 上下文
    func update(_ object: NSManagedObject, context: NSManagedObjectContext) throws {
        object.setValue(Date(), forKey: "updatedAt")
        try saveContext(context)
    }
    
    /// 删除实体（软删除）
    /// - Parameters:
    ///   - object: 要删除的实体
    ///   - context: 上下文
    func delete(_ object: NSManagedObject, context: NSManagedObjectContext) throws {
        object.setValue(Date(), forKey: "deletedAt")
        try saveContext(context)
    }
    
    /// 永久删除实体
    /// - Parameters:
    ///   - object: 要删除的实体
    ///   - context: 上下文
    func permanentDelete(_ object: NSManagedObject, context: NSManagedObjectContext) throws {
        context.delete(object)
        try saveContext(context)
    }
}

// MARK: - Batch Operations
extension CoreDataManager {
    /// 批量更新
    /// - Parameters:
    ///   - entityType: 实体类型
    ///   - predicate: 查询条件
    ///   - propertiesToUpdate: 要更新的属性
    ///   - context: 上下文
    func batchUpdate<T: NSManagedObject>(_ entityType: T.Type,
                                        predicate: NSPredicate? = nil,
                                        propertiesToUpdate: [AnyHashable: Any],
                                        context: NSManagedObjectContext) throws {
        let request = NSBatchUpdateRequest(entityName: String(describing: entityType))
        request.predicate = predicate
        request.propertiesToUpdate = propertiesToUpdate
        request.resultType = .updatedObjectIDsResultType
        
        let result = try context.execute(request) as? NSBatchUpdateResult
        let objectIDs = result?.result as? [NSManagedObjectID] ?? []
        
        let changes = [NSUpdatedObjectsKey: objectIDs]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
    }
    
    /// 批量删除
    /// - Parameters:
    ///   - entityType: 实体类型
    ///   - predicate: ��询条件
    ///   - context: 上下文
    func batchDelete<T: NSManagedObject>(_ entityType: T.Type,
                                        predicate: NSPredicate? = nil,
                                        context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: entityType))
        fetchRequest.predicate = predicate
        
        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        request.resultType = .resultTypeObjectIDs
        
        let result = try context.execute(request) as? NSBatchDeleteResult
        let objectIDs = result?.result as? [NSManagedObjectID] ?? []
        
        let changes = [NSDeletedObjectsKey: objectIDs]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
    }
} 