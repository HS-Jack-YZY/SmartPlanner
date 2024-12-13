import XCTest
import CoreData
@testable import SmartPlanner

/// PlanCategory 实体的单元测试
/// 测试范围：
/// - 基本属性的创建和验证
/// - 实体关系的管理
/// - 数据验证规则
/// - 边界条件处理
final class PlanCategoryTests: XCTestCase {
    
    // MARK: - Properties
    
    private var testStack: TestCoreDataStack!
    private var context: NSManagedObjectContext!
    private let logger = TestLogger.shared
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        logger.log("开始设置测试环境...", level: .info)
        testStack = TestCoreDataStack()
        context = testStack.context
        logger.log("测试环境设置完成", level: .info)
        
        // 验证环境
        let entityDescription = NSEntityDescription.entity(forEntityName: "PlanCategory", in: context)
        if entityDescription == nil {
            logger.log("无法找到 PlanCategory 实体描述", level: .error)
        } else {
            logger.log("找到 PlanCategory 实体描述", level: .info)
        }
    }
    
    override func tearDown() {
        testStack = nil
        context = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    /// 创建一个测试用的 PlanCategory 实例
    /// - Parameters:
    ///   - name: 类别名称
    ///   - level: 类别层级
    ///   - color: 类别颜色
    /// - Returns: 创建的 PlanCategory 实例
    private func createTestCategory(
        name: String = "测试类别",
        level: Int16 = 0,
        color: String = "#FF0000"
    ) throws -> NSManagedObject {
        logger.log("开始创建测试类别", level: .debug)
        logger.log("当前上下文: \(String(describing: context))", level: .debug)
        logger.log("可用实体: \(context.persistentStoreCoordinator?.managedObjectModel.entities ?? [])", level: .debug)
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "PlanCategory", in: context) else {
            let error = NSError(domain: "TestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法找到 PlanCategory 实体描述"])
            logger.logError(error)
            throw error
        }
        
        logger.log("找到实体描述: \(entityDescription)", level: .debug)
        let category = NSManagedObject(entity: entityDescription, insertInto: context)
        
        // 设置必要属性
        category.setValue(UUID(), forKey: "id")
        category.setValue(name, forKey: "name")
        category.setValue(level, forKey: "level")
        category.setValue(color, forKey: "color")
        category.setValue(0, forKey: "displayOrder")
        category.setValue(true, forKey: "isVisible")
        category.setValue(Date(), forKey: "createdAt")
        category.setValue(Date(), forKey: "updatedAt")
        
        logger.log("成功创建类别: \(name)", level: .info)
        return category
    }
    
    // MARK: - Basic Property Tests
    
    /// 测试创建基本的 PlanCategory 实例
    func test_createCategory_withValidData_shouldSucceed() throws {
        logger.logTestStart("test_createCategory_withValidData_shouldSucceed")
        
        // Given
        let name = "学习"
        let level: Int16 = 0
        let color = "#FF0000"
        
        // When
        let category = try createTestCategory(name: name, level: level, color: color)
        try context.save()
        
        // Then
        XCTAssertNotNil(category.value(forKey: "id"))
        XCTAssertEqual(category.value(forKey: "name") as? String, name)
        XCTAssertEqual(category.value(forKey: "level") as? Int16, level)
        XCTAssertEqual(category.value(forKey: "color") as? String, color)
        XCTAssertNotNil(category.value(forKey: "createdAt"))
        XCTAssertNotNil(category.value(forKey: "updatedAt"))
        
        logger.log("类别创建成功，所有属性验证通过", level: .info)
        logger.logTestEnd("test_createCategory_withValidData_shouldSucceed")
    }
    
    /// 测试创建没有必要属性的 PlanCategory 实例
    func test_createCategory_withoutRequiredProperties_shouldFail() throws {
        logger.logTestStart("test_createCategory_withoutRequiredProperties_shouldFail")
        
        // Given
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "PlanCategory", in: context) else {
            logger.log("无法找到 PlanCategory 实体描述", level: .error)
            XCTFail("无法找到 PlanCategory 实体描述")
            return
        }
        
        let category = NSManagedObject(entity: entityDescription, insertInto: context)
        
        // When & Then
        XCTAssertThrowsError(try context.save()) { error in
            let nsError = error as NSError
            logger.log("预期的验证错误: \(nsError)", level: .info)
            XCTAssertEqual(nsError.domain, NSCocoaErrorDomain)
            XCTAssertTrue(nsError.code == NSValidationErrorMinimum || nsError.code > NSValidationErrorMinimum)
        }
        
        logger.logTestEnd("test_createCategory_withoutRequiredProperties_shouldFail")
    }
    
    // MARK: - Validation Tests
    
    /// 测试类别层级的有效范围
    func test_categoryLevel_withInvalidValue_shouldFail() throws {
        logger.logTestStart("test_categoryLevel_withInvalidValue_shouldFail")
        
        // Given
        let invalidLevel: Int16 = -1
        
        // When
        let category = try createTestCategory(level: invalidLevel)
        
        // Then
        XCTAssertThrowsError(try context.save()) { error in
            let nsError = error as NSError
            logger.log("预期的验证错误: \(nsError)", level: .info)
            XCTAssertEqual(nsError.domain, NSCocoaErrorDomain)
            XCTAssertTrue(nsError.code == NSValidationErrorMinimum || nsError.code > NSValidationErrorMinimum)
        }
        
        logger.logTestEnd("test_categoryLevel_withInvalidValue_shouldFail")
    }
    
    /// 测试类别名称的长度限制
    func test_categoryName_withTooLongName_shouldFail() throws {
        logger.logTestStart("test_categoryName_withTooLongName_shouldFail")
        
        // Given
        let tooLongName = String(repeating: "测试", count: 51) // 超过100个字符
        
        // When
        let category = try createTestCategory(name: tooLongName)
        
        // Then
        XCTAssertThrowsError(try context.save()) { error in
            let nsError = error as NSError
            logger.log("预期的验证错误: \(nsError)", level: .info)
            XCTAssertEqual(nsError.domain, NSCocoaErrorDomain)
            XCTAssertTrue(nsError.code == NSValidationErrorMinimum || nsError.code > NSValidationErrorMinimum)
        }
        
        logger.logTestEnd("test_categoryName_withTooLongName_shouldFail")
    }
    
    // MARK: - Relationship Tests
    
    /// 测试父子类别关系
    func test_parentChildRelationship_shouldBeValid() throws {
        logger.logTestStart("test_parentChildRelationship_shouldBeValid")
        
        // Given
        let parent = try createTestCategory(name: "父类别", level: 0)
        let child = try createTestCategory(name: "子类别", level: 1)
        
        // When
        child.setValue(parent, forKey: "parent")
        try context.save()
        
        // Then
        XCTAssertEqual(child.value(forKey: "parent") as? NSManagedObject, parent)
        let parentChildren = parent.value(forKey: "children") as? NSSet
        XCTAssertTrue(parentChildren?.contains(child) ?? false)
        
        logger.log("父子关系验证成功", level: .info)
        logger.logTestEnd("test_parentChildRelationship_shouldBeValid")
    }
    
    /// 测试删除父类别时子类别的处理
    func test_deleteParentCategory_shouldCascadeToChildren() throws {
        logger.logTestStart("test_deleteParentCategory_shouldCascadeToChildren")
        
        // Given
        let parent = try createTestCategory(name: "父类别", level: 0)
        let child = try createTestCategory(name: "子类别", level: 1)
        child.setValue(parent, forKey: "parent")
        try context.save()
        
        // When
        context.delete(parent)
        try context.save()
        
        // Then
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PlanCategory")
        let remainingCategories = try context.fetch(fetchRequest)
        XCTAssertTrue(remainingCategories.isEmpty)
        
        logger.log("级联删除验证成功", level: .info)
        logger.logTestEnd("test_deleteParentCategory_shouldCascadeToChildren")
    }
} 