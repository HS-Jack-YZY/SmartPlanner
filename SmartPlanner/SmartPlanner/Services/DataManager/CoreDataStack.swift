import CoreData

/// Core Data 栈管理类，负责管理 Core Data 的基础设施
final class CoreDataStack {
    
    // MARK: - Properties
    
    private let logger = SPLogger.shared
    
    // MARK: - Singleton
    
    static let shared = CoreDataStack()
    
    private init() {
        logger.info("初始化 CoreDataStack", category: .coreData)
    }
    
    // MARK: - Core Data Stack
    
    /// 持久化容器
    lazy var persistentContainer: NSPersistentContainer = {
        logger.debug("初始化 PersistentContainer", category: .coreData)
        let container = NSPersistentContainer(name: "SmartPlanner")
        
        // 配置迁移选项
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        
        // 设置存储选项
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { [weak self] (storeDescription, error) in
            if let error = error as NSError? {
                self?.logger.error("Core Data 存储加载失败: \(error.localizedDescription)", 
                                 category: .coreData)
                
                // 尝试恢复
                self?.handlePersistentStoreError(error)
            } else {
                self?.logger.info("Core Data 存储加载成功", category: .coreData)
            }
        }
        
        logger.debug("配置 Core Data 上下文", category: .coreData)
        // 启用自动合并策略
        container.viewContext.automaticallyMergesChangesFromParent = true
        // 设置合并策略
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    /// 主线程上下文
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// 创建后台上下文
    func newBackgroundContext() -> NSManagedObjectContext {
        logger.debug("创建后台上下文", category: .coreData)
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - Core Data Operations
    
    /// 保存主上下文的更改
    func saveContext() {
        let context = mainContext
        if context.hasChanges {
            do {
                logger.debug("保存主上下文更改", category: .coreData)
                try context.save()
                logger.info("主上下文保存成功", category: .coreData)
            } catch {
                logger.error("主上下文保存失败: \(error.localizedDescription)", category: .coreData)
                handleSaveError(error)
            }
        }
    }
    
    /// 在后台上下文执行操作
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        logger.debug("执行后台任务", category: .coreData)
        persistentContainer.performBackgroundTask { [weak self] context in
            block(context)
            if context.hasChanges {
                do {
                    try context.save()
                    self?.logger.info("后台上下文保存成功", category: .coreData)
                } catch {
                    self?.logger.error("后台上下文保存失败: \(error.localizedDescription)", 
                                     category: .coreData)
                    self?.handleSaveError(error)
                }
            }
        }
    }
    
    // MARK: - Error Handling
    
    /// 处理持久化存储错误
    private func handlePersistentStoreError(_ error: NSError) {
        logger.error("处理持久化存储错误: \(error.localizedDescription)", category: .coreData)
        
        guard let storeURL = persistentContainer
            .persistentStoreDescriptions.first?
            .url else {
                logger.fault("无法获取存储 URL", category: .coreData)
                return
            }
        
        do {
            logger.notice("尝试删除损坏的存储: \(storeURL.path)", category: .coreData)
            // 尝试删除损坏的存储
            try persistentContainer.persistentStoreCoordinator
                .destroyPersistentStore(at: storeURL,
                                      ofType: NSSQLiteStoreType,
                                      options: nil)
            
            logger.notice("尝试重新加载存储", category: .coreData)
            // 重新加载存储
            try persistentContainer.persistentStoreCoordinator
                .addPersistentStore(ofType: NSSQLiteStoreType,
                                  configurationName: nil,
                                  at: storeURL,
                                  options: nil)
            
            logger.info("存储恢复成功", category: .coreData)
        } catch {
            logger.fault("恢复存储失败: \(error.localizedDescription)", category: .coreData)
        }
    }
    
    /// 处理保存错误
    private func handleSaveError(_ error: Error) {
        logger.error("处理保存错误: \(error.localizedDescription)", category: .coreData)
        
        let nsError = error as NSError
        if nsError.domain == NSCocoaErrorDomain,
           nsError.code == NSManagedObjectMergeError {
            
            logger.notice("检测到合并冲突，尝试解决", category: .coreData)
            // 重新获取并合并变更
            mainContext.refreshAllObjects()
            logger.info("已刷新所有对象", category: .coreData)
        }
    }
    
    // MARK: - Migration Support
    
    /// 检查是否需要迁移
    func requiresMigration() -> Bool {
        logger.debug("检查数据迁移需求", category: .coreData)
        
        guard let storeURL = persistentContainer
                .persistentStoreDescriptions.first?.url else {
            logger.error("无法获取存储 URL", category: .coreData)
            return false
        }
        
        do {
            // 获取元数据
            let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
                ofType: NSSQLiteStoreType,
                at: storeURL,
                options: nil
            )
            
            // 获取当前模型
            let model = persistentContainer.managedObjectModel
            
            // 检查兼容性
            let requiresMigration = !model.isConfiguration(withName: nil, 
                                                         compatibleWithStoreMetadata: metadata)
            
            if requiresMigration {
                logger.notice("检测到需要数据迁移", category: .coreData)
            } else {
                logger.debug("数据模型已是最新版本", category: .coreData)
            }
            
            return requiresMigration
        } catch {
            logger.error("检查迁移状态失败: \(error.localizedDescription)", category: .coreData)
            return false
        }
    }
    
    /// 执行轻量级迁移
    func performLightweightMigration() throws {
        logger.notice("开始执行轻量级迁移", category: .coreData)
        
        guard let storeURL = persistentContainer
                .persistentStoreDescriptions.first?.url else {
            let errorMessage = "无法获取存储 URL"
            logger.fault(errorMessage, category: .coreData)
            throw NSError(domain: "CoreDataStack",
                         code: -1,
                         userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        do {
            try persistentContainer.persistentStoreCoordinator
                .addPersistentStore(
                    ofType: NSSQLiteStoreType,
                    configurationName: nil,
                    at: storeURL,
                    options: options
                )
            logger.notice("轻量级迁移完成", category: .coreData)
        } catch {
            logger.fault("轻量级迁移失败: \(error.localizedDescription)", category: .coreData)
            throw error
        }
    }
} 