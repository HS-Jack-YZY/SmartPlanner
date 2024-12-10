//
//  CoreDataManagerTests.swift
//  SmartPlannerTests
//
//  Created by HS_Jack_YZY on 2024/12/11.
//

import XCTest
import CoreData
@testable import SmartPlanner

final class CoreDataManagerTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataManager = CoreDataManager.shared
    }
    
    override func tearDownWithError() throws {
        coreDataManager = nil
        try super.tearDownWithError()
    }
    
    // MARK: - 初始化测试
    
    func testSharedInstance() {
        // 测试单例模式
        let instance1 = CoreDataManager.shared
        let instance2 = CoreDataManager.shared
        XCTAssertTrue(instance1 === instance2, "CoreDataManager 应该是单例")
    }
    
    func testMainContext() {
        // 测试主上下文
        let context = coreDataManager.mainContext
        XCTAssertNotNil(context, "主上下文不应为空")
        XCTAssertEqual(context.concurrencyType, .mainQueueConcurrencyType, "主上下文应该是主队列类型")
    }
    
    func testNewBackgroundContext() {
        // 测试后台上下文
        let context = coreDataManager.newBackgroundContext()
        XCTAssertNotNil(context, "后台上下文不应为空")
        XCTAssertEqual(context.concurrencyType, .privateQueueConcurrencyType, "后台上下文应该是私有队列类型")
    }
    
    // MARK: - CRUD 操作测试
    
    func testCreateAndFetch() throws {
        // 创建测试实体
        let context = coreDataManager.mainContext
        let category = coreDataManager.create(Category.self, context: context)
        category.id = UUID()
        category.name = "测试类别"
        category.createdAt = Date()
        category.updatedAt = Date()
        
        // 保存
        try coreDataManager.saveContext(context)
        
        // 查询
        let predicate = NSPredicate(format: "name == %@", "测试类别")
        let fetchedCategories = try coreDataManager.fetch(Category.self,
                                                        predicate: predicate,
                                                        context: context)
        
        XCTAssertEqual(fetchedCategories.count, 1, "应该只找到一个类别")
        XCTAssertEqual(fetchedCategories.first?.name, "测试类别", "类别名称应该匹配")
        
        // 清理
        context.delete(category)
        try coreDataManager.saveContext(context)
    }
    
    func testUpdate() throws {
        // 创建测试实体
        let context = coreDataManager.mainContext
        let category = coreDataManager.create(Category.self, context: context)
        category.id = UUID()
        category.name = "原始名称"
        category.createdAt = Date()
        category.updatedAt = Date()
        
        try coreDataManager.saveContext(context)
        
        // 更新
        category.name = "更新名称"
        try coreDataManager.update(category, context: context)
        
        // 验证
        let predicate = NSPredicate(format: "name == %@", "更新名称")
        let fetchedCategories = try coreDataManager.fetch(Category.self,
                                                        predicate: predicate,
                                                        context: context)
        
        XCTAssertEqual(fetchedCategories.count, 1, "应该只找到一个类别")
        XCTAssertEqual(fetchedCategories.first?.name, "更新名称", "类别名称应该已更新")
        
        // 清理
        context.delete(category)
        try coreDataManager.saveContext(context)
    }
    
    func testDelete() throws {
        // 创建测试实体
        let context = coreDataManager.mainContext
        let category = coreDataManager.create(Category.self, context: context)
        category.id = UUID()
        category.name = "要删除的类别"
        category.createdAt = Date()
        category.updatedAt = Date()
        
        try coreDataManager.saveContext(context)
        
        // 软删除
        try coreDataManager.delete(category, context: context)
        
        // 验证软删除
        let predicate = NSPredicate(format: "name == %@ AND deletedAt != nil", "要删除的类别")
        let fetchedCategories = try coreDataManager.fetch(Category.self,
                                                        predicate: predicate,
                                                        context: context)
        
        XCTAssertEqual(fetchedCategories.count, 1, "应该找到一个已软删除的类别")
        XCTAssertNotNil(fetchedCategories.first?.deletedAt, "deletedAt 不应为空")
        
        // 永久删除
        try coreDataManager.permanentDelete(category, context: context)
        
        // 验证永久删除
        let allCategories = try coreDataManager.fetch(Category.self,
                                                    predicate: NSPredicate(format: "name == %@", "要删除的类别"),
                                                    context: context)
        
        XCTAssertEqual(allCategories.count, 0, "类别应该已被永久删除")
    }
    
    // MARK: - 批量操作测���
    
    func testBatchUpdate() throws {
        // 创建多个测试实体
        let context = coreDataManager.mainContext
        let count = 5
        
        for i in 0..<count {
            let category = coreDataManager.create(Category.self, context: context)
            category.id = UUID()
            category.name = "类别\(i)"
            category.createdAt = Date()
            category.updatedAt = Date()
            category.isVisible = true
        }
        
        try coreDataManager.saveContext(context)
        
        // 批量更新
        try coreDataManager.batchUpdate(Category.self,
                                      propertiesToUpdate: ["isVisible": false],
                                      context: context)
        
        // 验证
        let predicate = NSPredicate(format: "isVisible == NO")
        let updatedCategories = try coreDataManager.fetch(Category.self,
                                                        predicate: predicate,
                                                        context: context)
        
        XCTAssertEqual(updatedCategories.count, count, "所有类别的 isVisible 都应该被更新")
        
        // 清理
        try coreDataManager.batchDelete(Category.self, context: context)
    }
    
    func testBatchDelete() throws {
        // 创建多个测试实体
        let context = coreDataManager.mainContext
        let count = 5
        
        for i in 0..<count {
            let category = coreDataManager.create(Category.self, context: context)
            category.id = UUID()
            category.name = "要批量删除的类别\(i)"
            category.createdAt = Date()
            category.updatedAt = Date()
        }
        
        try coreDataManager.saveContext(context)
        
        // 批量删除
        let predicate = NSPredicate(format: "name BEGINSWITH %@", "要批量删除的类别")
        try coreDataManager.batchDelete(Category.self,
                                      predicate: predicate,
                                      context: context)
        
        // 验证
        let remainingCategories = try coreDataManager.fetch(Category.self,
                                                          predicate: predicate,
                                                          context: context)
        
        XCTAssertEqual(remainingCategories.count, 0, "所有匹配的类别都应该被删除")
    }
    
    // MARK: - 后台操作测试
    
    func testBackgroundOperation() throws {
        let expectation = XCTestExpectation(description: "后台操作完成")
        
        coreDataManager.performBackgroundTask { context in
            // 在后台创建实体
            let category = self.coreDataManager.create(Category.self, context: context)
            category.id = UUID()
            category.name = "后台创建的类别"
            category.createdAt = Date()
            category.updatedAt = Date()
            
            // 验证是在后台上下文
            XCTAssertEqual(context.concurrencyType, .privateQueueConcurrencyType)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // 验证创建结果
        let predicate = NSPredicate(format: "name == %@", "后台创建的类别")
        let fetchedCategories = try coreDataManager.fetch(Category.self,
                                                        predicate: predicate,
                                                        context: coreDataManager.mainContext)
        
        XCTAssertEqual(fetchedCategories.count, 1, "后台创建的类别应该可以在主上下文中查询到")
        
        // 清理
        if let category = fetchedCategories.first {
            coreDataManager.mainContext.delete(category)
            try coreDataManager.saveContext(coreDataManager.mainContext)
        }
    }
} 