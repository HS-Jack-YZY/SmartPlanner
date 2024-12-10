//
//  CategoryServiceTests.swift
//  SmartPlannerTests
//
//  Created by HS_Jack_YZY on 2024/12/11.
//

import XCTest
import CoreData
@testable import SmartPlanner

final class CategoryServiceTests: XCTestCase {
    
    var categoryService: CategoryService!
    var coreDataManager: CoreDataManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataManager = CoreDataManager.shared
        categoryService = CategoryService(coreDataManager: coreDataManager)
    }
    
    override func tearDownWithError() throws {
        categoryService = nil
        coreDataManager = nil
        try super.tearDownWithError()
    }
    
    // MARK: - 创建测试
    
    func testCreateCategory() throws {
        // 创建顶级类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        XCTAssertNotNil(category.id, "类别ID不应为空")
        XCTAssertEqual(category.name, "测试类别", "类别名称应该匹配")
        XCTAssertEqual(category.color, "#FF0000", "类别颜色应该匹配")
        XCTAssertEqual(category.level, 0, "顶级类别的层级应该为0")
        XCTAssertEqual(category.path, category.id?.uuidString, "顶级类别的路径应该是自己的ID")
        XCTAssertTrue(category.isVisible, "类别默认应该可见")
        
        // 清理
        try categoryService.deleteCategory(category)
    }
    
    func testCreateSubCategory() throws {
        // 创建父类别
        let parent = try categoryService.createCategory(name: "父类别", color: nil, parent: nil)
        
        // 创建子类别
        let child = try categoryService.createCategory(name: "子类别", color: nil, parent: parent)
        
        XCTAssertEqual(child.level, parent.level + 1, "子类别的层级应该是父类别+1")
        XCTAssertEqual(child.path, "\(parent.id!.uuidString)/\(child.id!.uuidString)", "子类别的路径应该包含父类别")
        XCTAssertEqual(child.parent, parent, "子类别的父类别引用应该正确")
        
        // 清理
        try categoryService.deleteCategory(parent) // 应该级联删除子类别
    }
    
    func testCreateCategoryWithDuplicateName() throws {
        // 创建第一个类别
        let category1 = try categoryService.createCategory(name: "重复名称", color: nil, parent: nil)
        
        // 尝试创建同名类别
        XCTAssertThrowsError(try categoryService.createCategory(name: "重复名称", color: nil, parent: nil)) { error in
            XCTAssertEqual(error as? CategoryError, .nameAlreadyExists)
        }
        
        // 清理
        try categoryService.deleteCategory(category1)
    }
    
    // MARK: - 查询测试
    
    func testFetchRootCategories() throws {
        // 创建多个类别
        let root1 = try categoryService.createCategory(name: "根类别1", color: nil, parent: nil)
        let root2 = try categoryService.createCategory(name: "根类别2", color: nil, parent: nil)
        let child = try categoryService.createCategory(name: "子类别", color: nil, parent: root1)
        
        // 获取根类别
        let rootCategories = try categoryService.fetchRootCategories()
        
        XCTAssertEqual(rootCategories.count, 2, "应该有两个根类别")
        XCTAssertTrue(rootCategories.contains(root1), "根类别1应该在结果中")
        XCTAssertTrue(rootCategories.contains(root2), "根类别2应该在结果中")
        XCTAssertFalse(rootCategories.contains(child), "子类别不应该在根类别结果中")
        
        // 清理
        try categoryService.deleteCategory(root1) // 会级联删除 child
        try categoryService.deleteCategory(root2)
    }
    
    func testFetchChildren() throws {
        // 创建父类别和多个子类别
        let parent = try categoryService.createCategory(name: "父类别", color: nil, parent: nil)
        let child1 = try categoryService.createCategory(name: "子类别1", color: nil, parent: parent)
        let child2 = try categoryService.createCategory(name: "子类别2", color: nil, parent: parent)
        let grandChild = try categoryService.createCategory(name: "孙类别", color: nil, parent: child1)
        
        // 获取子类别
        let children = try categoryService.fetchChildren(of: parent)
        
        XCTAssertEqual(children.count, 2, "应该有两个直接子类别")
        XCTAssertTrue(children.contains(child1), "子类别1应该在结果中")
        XCTAssertTrue(children.contains(child2), "子类别2应该在结果中")
        XCTAssertFalse(children.contains(grandChild), "孙类别不应该在直接子类别结果中")
        
        // 清理
        try categoryService.deleteCategory(parent) // 会级联删除所有子类别
    }
    
    func testFetchPath() throws {
        // 创建类别层级
        let root = try categoryService.createCategory(name: "根类别", color: nil, parent: nil)
        let child = try categoryService.createCategory(name: "子类别", color: nil, parent: root)
        let grandChild = try categoryService.createCategory(name: "孙类别", color: nil, parent: child)
        
        // 获取路径
        let path = try categoryService.fetchPath(for: grandChild)
        
        XCTAssertEqual(path.count, 3, "路径应该包含三个类别")
        XCTAssertEqual(path[0], root, "路径第一个应该是根类别")
        XCTAssertEqual(path[1], child, "路径第二个应该是子类别")
        XCTAssertEqual(path[2], grandChild, "路径第三个应该是孙类别")
        
        // 清理
        try categoryService.deleteCategory(root) // 会级联删除所有子类别
    }
    
    // MARK: - 更新测试
    
    func testUpdateCategory() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "原始名称", color: "#000000", parent: nil)
        
        // 更新类别
        try categoryService.updateCategory(category, name: "新名称", color: "#FFFFFF")
        
        XCTAssertEqual(category.name, "新名称", "类别名称应该已更新")
        XCTAssertEqual(category.color, "#FFFFFF", "类别颜色应该已更新")
        
        // 清理
        try categoryService.deleteCategory(category)
    }
    
    func testUpdateCategoryWithDuplicateName() throws {
        // 创建两个类别
        let category1 = try categoryService.createCategory(name: "类别1", color: nil, parent: nil)
        let category2 = try categoryService.createCategory(name: "类别2", color: nil, parent: nil)
        
        // 尝试将类别2的名称更新为类别1的名称
        XCTAssertThrowsError(try categoryService.updateCategory(category2, name: "类别1", color: nil)) { error in
            XCTAssertEqual(error as? CategoryError, .nameAlreadyExists)
        }
        
        // 清理
        try categoryService.deleteCategory(category1)
        try categoryService.deleteCategory(category2)
    }
    
    // MARK: - 移动测试
    
    func testMoveCategory() throws {
        // 创建类别层级
        let root1 = try categoryService.createCategory(name: "根类别1", color: nil, parent: nil)
        let root2 = try categoryService.createCategory(name: "根类别2", color: nil, parent: nil)
        let child = try categoryService.createCategory(name: "子类别", color: nil, parent: root1)
        
        // 移动类别
        try categoryService.moveCategory(child, to: root2)
        
        XCTAssertEqual(child.parent, root2, "类别的父类别应该已更新")
        XCTAssertEqual(child.level, root2.level + 1, "类别的层级应该已更新")
        XCTAssertEqual(child.path, "\(root2.id!.uuidString)/\(child.id!.uuidString)", "类别的路径应该已更新")
        
        // 清理
        try categoryService.deleteCategory(root1)
        try categoryService.deleteCategory(root2) // 会级联删除已移动的子类别
    }
    
    func testMoveCategoryToPreventCircularReference() throws {
        // 创建类别层级
        let root = try categoryService.createCategory(name: "根类别", color: nil, parent: nil)
        let child = try categoryService.createCategory(name: "子类别", color: nil, parent: root)
        let grandChild = try categoryService.createCategory(name: "孙类别", color: nil, parent: child)
        
        // 尝试将父类别移动到子类别下
        XCTAssertThrowsError(try categoryService.moveCategory(root, to: grandChild)) { error in
            XCTAssertEqual(error as? CategoryError, .circularReference)
        }
        
        // 清理
        try categoryService.deleteCategory(root) // 会级联删除所有子类别
    }
    
    // MARK: - 删除测试
    
    func testDeleteCategory() throws {
        // 创建类别层级
        let root = try categoryService.createCategory(name: "根类别", color: nil, parent: nil)
        let child = try categoryService.createCategory(name: "子类别", color: nil, parent: root)
        let grandChild = try categoryService.createCategory(name: "孙类别", color: nil, parent: child)
        
        // 删除根类别
        try categoryService.deleteCategory(root)
        
        // 验证所有类别都被软删除
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: "deletedAt != nil")
        let deletedCategories = try coreDataManager.fetch(Category.self,
                                                        predicate: predicate,
                                                        context: context)
        
        XCTAssertEqual(deletedCategories.count, 3, "所有类别都应该被软删除")
        XCTAssertTrue(deletedCategories.contains(root), "根类别应该被软删除")
        XCTAssertTrue(deletedCategories.contains(child), "子类别应该被软删除")
        XCTAssertTrue(deletedCategories.contains(grandChild), "孙类别应该被软删除")
        
        // 永久删除（清理）
        context.delete(root) // 会级联永久删除所有子类别
        try coreDataManager.saveContext(context)
    }
} 