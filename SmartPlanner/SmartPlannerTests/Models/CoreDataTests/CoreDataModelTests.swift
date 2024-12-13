import XCTest
import CoreData
@testable import SmartPlanner

/// 测试 Core Data 模型加载和基本配置
final class CoreDataModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var modelBundle: Bundle!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        modelBundle = Bundle(for: type(of: self))
        print("测试环境设置完成")
        print("使用的 Bundle: \(modelBundle)")
    }
    
    override func tearDown() {
        modelBundle = nil
        super.tearDown()
    }
    
    // MARK: - Model Loading Tests
    
    /// 测试是否能找到模型文件
    func test_modelFile_shouldExist() {
        // Given
        let modelName = "SmartPlanner"
        
        // When
        let modelURL = modelBundle.url(forResource: modelName, withExtension: "momd")
        
        // Then
        XCTAssertNotNil(modelURL, "应该能找到模型文件")
        print("模型文件 URL: \(modelURL ?? URL(fileURLWithPath: ""))")
    }
    
    /// 测试是否能加载模型
    func test_modelLoading_shouldSucceed() {
        // Given
        let modelName = "SmartPlanner"
        guard let modelURL = modelBundle.url(forResource: modelName, withExtension: "momd") else {
            XCTFail("找不到模型文件")
            return
        }
        
        // When
        let model = NSManagedObjectModel(contentsOf: modelURL)
        
        // Then
        XCTAssertNotNil(model, "应该能加载模型")
        if let model = model {
            print("模型加载成功")
            print("实体列表：")
            model.entities.forEach { entity in
                print("- \(entity.name ?? "未命名")")
                print("  属性：\(entity.properties.map { $0.name })")
                print("  关系：\(entity.relationshipsByName.keys)")
            }
        }
    }
    
    /// 测试 PlanCategory 实体配置
    func test_planCategoryEntity_shouldBeConfiguredCorrectly() {
        // Given
        let modelName = "SmartPlanner"
        guard let modelURL = modelBundle.url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            XCTFail("无法加载模型")
            return
        }
        
        // When
        let planCategoryEntity = model.entitiesByName["PlanCategory"]
        
        // Then
        XCTAssertNotNil(planCategoryEntity, "应该能找到 PlanCategory 实体")
        
        if let entity = planCategoryEntity {
            print("\nPlanCategory 实体配置：")
            print("名称：\(entity.name ?? "")")
            print("类名：\(entity.managedObjectClassName)")
            
            // 检查属性
            print("\n属性：")
            entity.properties.forEach { property in
                print("- \(property.name): \(type(of: property))")
            }
            
            // 检查关系
            print("\n关系：")
            entity.relationshipsByName.forEach { name, relationship in
                print("- \(name):")
                print("  目标实体：\(relationship.destinationEntity?.name ?? "未知")")
                print("  可选性：\(relationship.isOptional)")
                print("  类型：\(relationship.isToMany ? "一对多" : "一对一")")
            }
        }
    }
    
    /// 测试创建持久化存储协调器
    func test_persistentStoreCoordinator_shouldInitialize() {
        // Given
        let modelName = "SmartPlanner"
        guard let modelURL = modelBundle.url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            XCTFail("无法加载模型")
            return
        }
        
        // When
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSInMemoryStoreType
        
        // Then
        let expectation = XCTestExpectation(description: "添加持久化存储")
        
        coordinator.addPersistentStore(with: storeDescription) { (store, error) in
            if let error = error {
                XCTFail("添加存储失败: \(error)")
            } else {
                print("成功创建持久化存储")
                print("存储类型：\(storeDescription.type)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
} 