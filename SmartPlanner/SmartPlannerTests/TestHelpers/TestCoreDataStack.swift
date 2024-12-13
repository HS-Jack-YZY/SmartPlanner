import CoreData
@testable import SmartPlanner

/// 测试用 Core Data 错误类型
enum TestCoreDataError: Error {
    case modelNotFound(String)
    case modelLoadFailed(URL)
    case storeCreationFailed(Error)
    case emptyStore
    
    var localizedDescription: String {
        switch self {
        case .modelNotFound(let name):
            return "无法找到 Core Data 模型文件: \(name).momd"
        case .modelLoadFailed(let url):
            return "无法加载 Core Data 模型: \(url.path)"
        case .storeCreationFailed(let error):
            return "无法创建持久化存储: \(error.localizedDescription)"
        case .emptyStore:
            return "创建持久化存储失败: store 为空"
        }
    }
}

/// 用于测试的 Core Data 栈
/// 使用内存存储以提高测试速度并避免影响实际数据库
final class TestCoreDataStack {
    
    // MARK: - Properties
    
    /// 日志工具
    private let logger = TestLogger.shared
    
    /// 模型名称
    private let modelName = "SmartPlanner"
    
    /// 托管对象模型
    private let model: NSManagedObjectModel
    
    /// 持久化存储协调器
    private let storeCoordinator: NSPersistentStoreCoordinator
    
    /// 托管对象上下文
    private(set) var context: NSManagedObjectContext
    
    // MARK: - Initialization
    
    /// 初始化测试用 Core Data 栈
    /// - Throws: TestCoreDataError 如果初始化过程中发生错误
    init() throws {
        logger.log("开始初始化 TestCoreDataStack", level: .info)
        
        // 1. 加载模型
        model = try TestCoreDataStack.loadModel(name: modelName)
        
        // 2. 创建协调器
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // 3. 设置并添加内存存储
        try TestCoreDataStack.setupInMemoryStore(for: storeCoordinator)
        
        // 4. 创建上下文
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = storeCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        logger.log("TestCoreDataStack 初始化完成", level: .info)
    }
    
    // MARK: - Private Methods
    
    /// 加载 Core Data 模型
    /// - Parameter name: 模型名称
    /// - Returns: 加载的托管对象模型
    /// - Throws: TestCoreDataError 如果模型加载失败
    private static func loadModel(name: String) throws -> NSManagedObjectModel {
        let bundle = Bundle(for: TestCoreDataStack.self)
        
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd") else {
            throw TestCoreDataError.modelNotFound(name)
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw TestCoreDataError.modelLoadFailed(modelURL)
        }
        
        return model
    }
    
    /// 设置内存存储
    /// - Parameter coordinator: 持久化存储协调器
    /// - Throws: TestCoreDataError 如果存储创建失败
    private static func setupInMemoryStore(for coordinator: NSPersistentStoreCoordinator) throws {
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        coordinator.addPersistentStore(with: description) { store, error in
            if let error = error {
                fatalError("创建持久化存储失败: \(error)")
            }
            guard store != nil else {
                fatalError("创建持久化存储失败: store 为空")
            }
        }
    }
    
    // MARK: - Deinitializer
    
    deinit {
        logger.log("TestCoreDataStack 被释放", level: .debug)
    }
}

// MARK: - Convenience Methods

extension TestCoreDataStack {
    /// 保存上下文更改
    /// - Throws: 如果保存失败则抛出错误
    func saveContext() throws {
        if context.hasChanges {
            logger.log("保存上下文更改", level: .debug)
            try context.save()
            logger.log("上下文保存成功", level: .info)
        }
    }
    
    /// 回滚上下文更改
    func rollbackContext() {
        if context.hasChanges {
            logger.log("回滚上下文更改", level: .debug)
            context.rollback()
            logger.log("上下文回滚完成", level: .info)
        }
    }
} 