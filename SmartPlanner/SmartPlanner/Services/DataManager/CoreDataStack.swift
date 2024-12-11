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
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // 在实际应用中，应该适当处理这个错误
                // 这里我们先打印错误信息
                print("Unresolved error \(error), \(error.userInfo)")
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
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Core Data Operations
    
    /// 保存主上下文的更改
    func saveContext() {
        let context = mainContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // 在实际应用中，应该适当处理这个错误
                print("Error saving context: \(error)")
            }
        }
    }
    
    /// 在后台上下文执行操作
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { context in
            block(context)
            // 如果上下文有更改，尝试保存
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Error saving background context: \(error)")
                }
            }
        }
    }
} 