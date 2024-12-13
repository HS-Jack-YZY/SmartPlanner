import CoreData
@testable import SmartPlanner

/// 用于测试的 Core Data 栈
/// 使用内存存储以提高测试速度并避免影响实际数据库
final class TestCoreDataStack {
    
    // MARK: - Properties
    
    /// 日志工具
    private let logger = TestLogger.shared
    
    /// 托管对象模型
    private let model: NSManagedObjectModel = {
        // 从主应用 Bundle 中获取模型
        let modelName = "SmartPlanner"
        let bundle = Bundle(for: TestCoreDataStack.self)
        
        guard let modelURL = bundle.url(forResource: modelName, withExtension: "momd") else {
            TestLogger.shared.log("无法找到 Core Data 模型文件: \(modelName).momd", level: .error)
            fatalError("无法找到 Core Data 模型文件")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            TestLogger.shared.log("无法加载 Core Data 模型: \(modelURL.path)", level: .error)
            fatalError("无法加载 Core Data 模型")
        }
        
        TestLogger.shared.log("成功加载 Core Data 模型", level: .info)
        return model
    }()
    
    /// 持久化存储协调器
    private lazy var storeCoordinator: NSPersistentStoreCoordinator = {
        logger.log("初始化持久化存储协调器", level: .debug)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        // 同步添加存储
        coordinator.addPersistentStore(with: description) { (store, error) in
            if let error = error {
                self.logger.log("无法创建持久化存储: \(error)", level: .error)
                fatalError("无法创建持久化存储: \(error)")
            }
            if let store = store {
                self.logger.log("成功创建内存存储: \(store.description)", level: .info)
            }
        }
        
        return coordinator
    }()
    
    /// 托管对象上下文
    lazy var context: NSManagedObjectContext = {
        logger.log("初始化托管对象上下文", level: .debug)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = storeCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        logger.log("托管对象上下文初始化完成", level: .info)
        return context
    }()
    
    // MARK: - Initialization
    
    init() {
        logger.log("初始化 TestCoreDataStack", level: .info)
        if let modelURL = Bundle(for: TestCoreDataStack.self).url(forResource: "SmartPlanner", withExtension: "momd") {
            logger.log("找到模型文件: \(modelURL.path)", level: .debug)
        } else {
            logger.log("未找到模型文件", level: .error)
        }
        
        logger.log("可用实体:", level: .debug)
        model.entities.forEach { entity in
            logger.log("- \(entity.name ?? "未命名")", level: .debug)
            logger.log("  属性: \(entity.properties.map { $0.name })", level: .debug)
            logger.log("  关系: \(entity.relationshipsByName.keys)", level: .debug)
        }
        
        _ = context
        logger.log("TestCoreDataStack 初始化完成", level: .info)
    }
    
    // MARK: - Public Methods
    
    /// 保存上下文中的更改
    func saveContext() throws {
        if context.hasChanges {
            logger.log("保存上下文更改", level: .debug)
            do {
                try context.save()
                logger.log("上下文保存成功", level: .info)
            } catch {
                logger.logError(error)
                throw error
            }
        } else {
            logger.log("上下文没有需要保存的更改", level: .debug)
        }
    }
    
    /// 重置所有数据
    func resetStore() {
        logger.log("开始重置存储", level: .info)
        let entities = model.entities
        
        // 删除所有实体的数据
        entities.forEach { entity in
            guard let entityName = entity.name else {
                logger.log("实体名称为空", level: .warning)
                return
            }
            
            logger.log("正在重置实体: \(entityName)", level: .debug)
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try storeCoordinator.execute(deleteRequest, with: context)
                logger.log("成功重置实体: \(entityName)", level: .debug)
            } catch {
                logger.log("重置实体 \(entityName) 时出错: \(error)", level: .error)
            }
        }
        
        // 保存更改
        do {
            try context.save()
            logger.log("存储重置完成", level: .info)
        } catch {
            logger.log("保存重置更改时出错: \(error)", level: .error)
        }
    }
} 