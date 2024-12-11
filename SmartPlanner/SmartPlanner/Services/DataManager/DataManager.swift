import CoreData
import Combine

/// 数据管理器，提供对 Core Data 的统一访问接口
final class DataManager {
    
    // MARK: - Properties
    
    private let coreDataStack: CoreDataStack
    
    // MARK: - Initialization
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - CRUD Operations
    
    /// 创建新的实体对象
    func create<T: NSManagedObject>(_ type: T.Type) -> T {
        return T(context: coreDataStack.mainContext)
    }
    
    /// 保存更改
    func save() throws {
        do {
            try coreDataStack.mainContext.save()
        } catch {
            throw DataManagerError.saveFailed(error)
        }
    }
    
    /// 异步保存更改
    func saveAsync() async throws {
        try await coreDataStack.mainContext.perform {
            do {
                try self.coreDataStack.mainContext.save()
            } catch {
                throw DataManagerError.saveFailed(error)
            }
        }
    }
    
    /// 获取实体对象
    func fetch<T: NSManagedObject>(_ type: T.Type,
                                  predicate: NSPredicate? = nil,
                                  sortDescriptors: [NSSortDescriptor]? = nil) throws -> [T] {
        let request = T.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            let result = try coreDataStack.mainContext.fetch(request)
            return result as? [T] ?? []
        } catch {
            throw DataManagerError.fetchFailed(error)
        }
    }
    
    /// 异步获取实体对象
    func fetchAsync<T: NSManagedObject>(_ type: T.Type,
                                       predicate: NSPredicate? = nil,
                                       sortDescriptors: [NSSortDescriptor]? = nil) async throws -> [T] {
        try await coreDataStack.mainContext.perform {
            let request = T.fetchRequest()
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            
            do {
                let result = try self.coreDataStack.mainContext.fetch(request)
                return result as? [T] ?? []
            } catch {
                throw DataManagerError.fetchFailed(error)
            }
        }
    }
    
    /// 删除实体对象
    func delete(_ object: NSManagedObject) throws {
        coreDataStack.mainContext.delete(object)
        do {
            try save()
        } catch {
            throw DataManagerError.deleteFailed(error)
        }
    }
    
    /// 异步删除实体对象
    func deleteAsync(_ object: NSManagedObject) async throws {
        try await coreDataStack.mainContext.perform {
            self.coreDataStack.mainContext.delete(object)
            do {
                try self.save()
            } catch {
                throw DataManagerError.deleteFailed(error)
            }
        }
    }
    
    /// 批量删除实体对象
    func deleteAll<T: NSManagedObject>(_ type: T.Type) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coreDataStack.mainContext.execute(deleteRequest)
            try save()
        } catch {
            throw DataManagerError.deleteFailed(error)
        }
    }
    
    // MARK: - Background Operations
    
    /// 在后台执行操作
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) throws -> Void) async throws {
        try await withCheckedThrowingContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                do {
                    try block(context)
                    if context.hasChanges {
                        try context.save()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: DataManagerError.unknown(error))
                }
            }
        }
    }
} 