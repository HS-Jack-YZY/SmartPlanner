import CoreData
@testable import SmartPlanner

/// 用于测试的 Core Data 栈
/// 使用内存存储以提高测试速度并避免影响实际数据库
final class TestCoreDataStack {
    
    // MARK: - Properties
    
    /// 托管对象模型
    private let model: NSManagedObjectModel = {
        // 从主应用 Bundle 中获取模型
        let modelURL = Bundle(for: SmartPlannerApp.self)
            .url(forResource: "SmartPlanner", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        return model
    }()
    
    /// 持久化存储协调器
    private lazy var storeCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        // 同步添加存储
        coordinator.addPersistentStore(with: description) { (store, error) in
            if let error = error {
                fatalError("无法创建持久化存储: \(error)")
            }
        }
        
        return coordinator
    }()
    
    /// 托管对象上下文
    lazy var context: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = storeCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    // MARK: - Initialization
    
    init() {
        print("初始化 TestCoreDataStack")
        print("模型 URL: \(Bundle(for: SmartPlannerApp.self).url(forResource: "SmartPlanner", withExtension: "momd") ?? "未找到")")
        print("实体描述: \(model.entities)")
        _ = context
    }
    
    // MARK: - Public Methods
    
    /// 保存上下文中的更改
    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    /// 重置所有数据
    func resetStore() {
        let entities = model.entities
        
        // 删除所有实体的数据
        entities.forEach { entity in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.name!)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try storeCoordinator.execute(deleteRequest, with: context)
            } catch {
                print("重置实体 \(entity.name!) 时出错: \(error)")
            }
        }
        
        // 保存更改
        do {
            try context.save()
        } catch {
            print("保存重置更改时出错: \(error)")
        }
    }
} 