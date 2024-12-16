import CoreData

/// Core Data 栈管理类，负责管理 Core Data 的基础设施
final class CoreDataStack {
    
    // MARK: - Singleton
    
    static let shared = CoreDataStack()
    
    private init() {}
    
    // MARK: - Core Data Stack
    
    /// 持久化容器
    lazy var persistentContainer: NSPersistentContainer = {
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
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // 记录错误信息
                print("Core Data 存储加载失败: \(error), \(error.userInfo)")
                
                // 尝试恢复
                self.handlePersistentStoreError(error)
            }
        }
        
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
                try context.save()
            } catch {
                handleSaveError(error)
            }
        }
    }
    
    /// 在后台上下文执行操作
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { context in
            block(context)
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    self.handleSaveError(error)
                }
            }
        }
    }
    
    // MARK: - Error Handling
    
    /// 处理持久化存储错误
    private func handlePersistentStoreError(_ error: NSError) {
        // 获取存储 URL
        guard let storeURL = persistentContainer
            .persistentStoreDescriptions.first?
            .url else { return }
        
        do {
            // 尝试删除损坏的存储
            try persistentContainer.persistentStoreCoordinator
                .destroyPersistentStore(at: storeURL,
                                      ofType: NSSQLiteStoreType,
                                      options: nil)
            
            // 重新加载存储
            try persistentContainer.persistentStoreCoordinator
                .addPersistentStore(ofType: NSSQLiteStoreType,
                                  configurationName: nil,
                                  at: storeURL,
                                  options: nil)
            
        } catch {
            print("恢复存储失败: \(error)")
        }
    }
    
    /// 处理保存错误
    private func handleSaveError(_ error: Error) {
    print("保存上下文失败: \(error)")
    
    let nsError = error as NSError  // 安全的转换
    if nsError.domain == NSCocoaErrorDomain,
       nsError.code == NSManagedObjectMergeError {
        
        // 重新获取并合并变更
        mainContext.refreshAllObjects()
        }
    }
    
    // MARK: - Migration Support
    
    /// 检查是否需要迁移
    func requiresMigration() -> Bool {
        guard let storeURL = persistentContainer
                .persistentStoreDescriptions.first?.url else {
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
            return !model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        } catch {
            print("检查迁移状态失败: \(error)")
            return false
        }
    }
    
    /// 执行轻量级迁移
    func performLightweightMigration() throws {
        guard let storeURL = persistentContainer
                .persistentStoreDescriptions.first?.url else {
            throw NSError(domain: "CoreDataStack",
                         code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "无法获取存储 URL"])
        }
        
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        try persistentContainer.persistentStoreCoordinator
            .addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: options
            )
    }
} 