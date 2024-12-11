import XCTest
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
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        testStack = TestCoreDataStack()
        context = testStack.context
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
    ) throws -> PlanCategory {
        let category = PlanCategory(context: context)
        category.id = UUID()
        category.name = name
        category.level = level
        category.color = color
        category.displayOrder = 0
        category.createdAt = Date()
        category.updatedAt = Date()
        return category
    }
    
    // MARK: - Basic Property Tests
    
    /// 测试创建基本的 PlanCategory 实例
    func test_createCategory_withValidData_shouldSucceed() throws {
        // Given
        let name = "学习"
        let level: Int16 = 0
        let color = "#FF0000"
        
        // When
        let category = try createTestCategory(name: name, level: level, color: color)
        try context.save()
        
        // Then
        XCTAssertNotNil(category.id)
        XCTAssertEqual(category.name, name)
        XCTAssertEqual(category.level, level)
        XCTAssertEqual(category.color, color)
        XCTAssertNotNil(category.createdAt)
        XCTAssertNotNil(category.updatedAt)
    }
    
    /// 测试创建没有必要属性的 PlanCategory 实例
    func test_createCategory_withoutRequiredProperties_shouldFail() {
        // Given
        let category = PlanCategory(context: context)
        
        // When & Then
        XCTAssertThrowsError(try context.save()) { error in
            XCTAssertTrue(error is NSValidationError)
        }
    }
    
    // MARK: - Validation Tests
    
    /// 测试类别层级的有效范围
    func test_categoryLevel_withInvalidValue_shouldFail() throws {
        // Given
        let invalidLevel: Int16 = -1
        
        // When
        let category = try createTestCategory(level: invalidLevel)
        
        // Then
        XCTAssertThrowsError(try context.save()) { error in
            XCTAssertTrue(error is NSValidationError)
        }
    }
    
    /// 测试类别名称的长度限制
    func test_categoryName_withTooLongName_shouldFail() throws {
        // Given
        let tooLongName = String(repeating: "测试", count: 51) // 超过100个字符
        
        // When
        let category = try createTestCategory(name: tooLongName)
        
        // Then
        XCTAssertThrowsError(try context.save()) { error in
            XCTAssertTrue(error is NSValidationError)
        }
    }
    
    // MARK: - Relationship Tests
    
    /// 测试父子类别关系
    func test_parentChildRelationship_shouldBeValid() throws {
        // Given
        let parent = try createTestCategory(name: "父类别", level: 0)
        let child = try createTestCategory(name: "子类别", level: 1)
        
        // When
        child.parent = parent
        try context.save()
        
        // Then
        XCTAssertEqual(child.parent, parent)
        XCTAssertTrue(parent.children?.contains(child) ?? false)
    }
    
    /// 测试删除父类别时子类别的处理
    func test_deleteParentCategory_shouldCascadeToChildren() throws {
        // Given
        let parent = try createTestCategory(name: "父类别", level: 0)
        let child = try createTestCategory(name: "子类别", level: 1)
        child.parent = parent
        try context.save()
        
        // When
        context.delete(parent)
        try context.save()
        
        // Then
        let fetchRequest: NSFetchRequest<PlanCategory> = PlanCategory.fetchRequest()
        let remainingCategories = try context.fetch(fetchRequest)
        XCTAssertTrue(remainingCategories.isEmpty)
    }
} 