import CoreData
import Combine

/// 数据管理器，提供对 Core Data 的统一访问接口
final class DataManager {
    
    // MARK: - Properties
    
    private let coreDataStack: CoreDataStack
    private let logger = SPLogger.shared
    
    // MARK: - Initialization
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
        logger.info("初始化 DataManager", category: .coreData)
    }
    
    // MARK: - Migration Support
    
    /// 检查并执行必要的数据迁移
    func performNecessaryMigrations() async throws {
        logger.notice("检查数据迁移需求", category: .coreData)
        // 检查是否需要迁移
        guard coreDataStack.requiresMigration() else {
            logger.info("无需数据迁移", category: .coreData)
            return
        }
        
        logger.notice("开始执行数据迁移", category: .coreData)
        // 执行迁移
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try self.coreDataStack.performLightweightMigration()
                    self.logger.notice("数据迁移成功完成", category: .coreData)
                    continuation.resume()
                } catch {
                    self.logger.error("数据迁移失败: \(error.localizedDescription)", 
                                    category: .coreData)
                    continuation.resume(throwing: DataManagerError.migrationFailed(error))
                }
            }
        }
    }
    
    // MARK: - CRUD Operations
    
    /// 创建新的实体对象
    func create<T: NSManagedObject>(_ type: T.Type) -> T {
        logger.debug("创建新的实体对象: \(String(describing: type))", category: .coreData)
        return T(context: coreDataStack.mainContext)
    }
    
    /// 保存更改
    func save() throws {
        logger.debug("保存上下文更改", category: .coreData)
        do {
            try coreDataStack.mainContext.save()
            logger.info("上下文保存成功", category: .coreData)
        } catch {
            logger.error("上下文保存失败: \(error.localizedDescription)", category: .coreData)
            throw DataManagerError.saveFailed(error)
        }
    }
    
    /// 异步保存更改
    func saveAsync() async throws {
        logger.debug("异步保存上下文更改", category: .coreData)
        try await coreDataStack.mainContext.perform {
            do {
                try self.coreDataStack.mainContext.save()
                self.logger.info("异步上下文保存成功", category: .coreData)
            } catch {
                self.logger.error("异步上下文保存失败: \(error.localizedDescription)", 
                                category: .coreData)
                throw DataManagerError.saveFailed(error)
            }
        }
    }
    
    /// 获取实体对象
    func fetch<T: NSManagedObject>(_ type: T.Type,
                                  predicate: NSPredicate? = nil,
                                  sortDescriptors: [NSSortDescriptor]? = nil) throws -> [T] {
        logger.debug("获取实体对象: \(String(describing: type))", category: .coreData)
        let request = T.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            let result = try coreDataStack.mainContext.fetch(request)
            let count = (result as? [T])?.count ?? 0
            logger.debug("获取到 \(count) 个实体对象", category: .coreData)
            return result as? [T] ?? []
        } catch {
            logger.error("获取实体对象失败: \(error.localizedDescription)", category: .coreData)
            throw DataManagerError.fetchFailed(error)
        }
    }
    
    /// 异步获取实体对象
    func fetchAsync<T: NSManagedObject>(_ type: T.Type,
                                      predicate: NSPredicate? = nil,
                                      sortDescriptors: [NSSortDescriptor]? = nil) async throws -> [T] {
        logger.debug("异步获取实体对象: \(String(describing: type))", category: .coreData)
        
        return try await coreDataStack.mainContext.perform {
            let request = T.fetchRequest()
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            
            do {
                let result = try self.coreDataStack.mainContext.fetch(request)
                let count = (result as? [T])?.count ?? 0
                self.logger.debug("异步获取到 \(count) 个实体对象", category: .coreData)
                return result as? [T] ?? []
            } catch {
                self.logger.error("异步获取实体对象失败: \(error.localizedDescription)", 
                                category: .coreData)
                throw DataManagerError.fetchFailed(error)
            }
        }
    }
    
    /// 删除实体对象
    func delete(_ object: NSManagedObject) throws {
        logger.debug("删除实体对象: \(object)", category: .coreData)
        coreDataStack.mainContext.delete(object)
        do {
            try save()
            logger.info("实体对象删除成功", category: .coreData)
        } catch {
            logger.error("删除实体对象失败: \(error.localizedDescription)", category: .coreData)
            throw DataManagerError.deleteFailed(error)
        }
    }
    
    /// 异���删除实体对象
    func deleteAsync(_ object: NSManagedObject) async throws {
        logger.debug("异步删除实体对象: \(object)", category: .coreData)
        try await coreDataStack.mainContext.perform {
            self.coreDataStack.mainContext.delete(object)
            do {
                try self.save()
                self.logger.info("异步删除实体对象成功", category: .coreData)
            } catch {
                self.logger.error("异步删除实体对象失败: \(error.localizedDescription)", 
                                category: .coreData)
                throw DataManagerError.deleteFailed(error)
            }
        }
    }
    
    /// 批量删除实体对象
    func deleteAll<T: NSManagedObject>(_ type: T.Type) throws {
        logger.notice("批量删除实体对象: \(String(describing: type))", category: .coreData)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coreDataStack.mainContext.execute(deleteRequest)
            try save()
            logger.notice("批量删除成功完成", category: .coreData)
        } catch {
            logger.error("批量删除失败: \(error.localizedDescription)", category: .coreData)
            throw DataManagerError.deleteFailed(error)
        }
    }
    
    // MARK: - Background Operations
    
    /// 在后台执行操作
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) throws -> Void) async throws {
        logger.debug("执行后台任务", category: .coreData)
        try await withCheckedThrowingContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                do {
                    try block(context)
                    if context.hasChanges {
                        try context.save()
                    }
                    self.logger.debug("后台任务成功完成", category: .coreData)
                    continuation.resume()
                } catch {
                    self.logger.error("后台任务失败: \(error.localizedDescription)", 
                                    category: .coreData)
                    continuation.resume(throwing: DataManagerError.unknown(error))
                }
            }
        }
    }
} 