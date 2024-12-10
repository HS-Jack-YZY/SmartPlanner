//
//  PlanTemplateServiceTests.swift
//  SmartPlannerTests
//
//  Created by HS_Jack_YZY on 2024/12/11.
//

import XCTest
import CoreData
@testable import SmartPlanner

final class PlanTemplateServiceTests: XCTestCase {
    
    var planTemplateService: PlanTemplateService!
    var categoryService: CategoryService!
    var coreDataManager: CoreDataManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataManager = CoreDataManager.shared
        categoryService = CategoryService(coreDataManager: coreDataManager)
        planTemplateService = PlanTemplateService(coreDataManager: coreDataManager)
    }
    
    override func tearDownWithError() throws {
        planTemplateService = nil
        categoryService = nil
        coreDataManager = nil
        try super.tearDownWithError()
    }
    
    // MARK: - 创建测试
    
    func testCreatePlanTemplate() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 创建计划模板
        let template = try planTemplateService.createTemplate(
            name: "测试计划模板",
            category: category,
            color: "#00FF00",
            isFixedTime: false,
            isReminderEnabled: false,
            reminderTime: nil,
            priority: 1,
            difficulty: 2,
            tags: nil
        )
        
        XCTAssertNotNil(template.id, "模板ID不应为空")
        XCTAssertEqual(template.name, "测试计划模板", "模板名称应该匹配")
        XCTAssertEqual(template.category, category, "模板类别应该匹配")
        XCTAssertEqual(template.priority, 1, "模板优先级应该匹配")
        XCTAssertEqual(template.difficulty, 2, "模板难度应该匹配")
        XCTAssertFalse(template.isFixedTime, "模板固定时间标志应该匹配")
        XCTAssertEqual(template.color, "#00FF00", "模板颜色应该匹配")
        XCTAssertEqual(template.tags, nil, "模板标签应该匹配")
        XCTAssertNotNil(template.createdAt, "创建时间不应为空")
        XCTAssertNotNil(template.updatedAt, "更新时间不应为空")
        XCTAssertNil(template.deletedAt, "删除时间应为空")
        
        // 清理
        try planTemplateService.deleteTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    func testCreatePlanTemplateWithDuplicateName() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 创建第一个模板
        let template1 = try planTemplateService.createTemplate(
            name: "重复名称",
            category: category,
            color: nil,
            isFixedTime: false,
            isReminderEnabled: false,
            reminderTime: nil,
            priority: 1,
            difficulty: 1,
            tags: nil
        )
        
        // 尝试创建同名模板
        XCTAssertThrowsError(try planTemplateService.createTemplate(
            name: "重复名称",
            category: category,
            color: nil,
            isFixedTime: true,
            isReminderEnabled: false,
            reminderTime: nil,
            priority: 2,
            difficulty: 2,
            tags: nil
        )) { error in
            XCTAssertEqual(error as? PlanTemplateError, .nameAlreadyExists)
        }
        
        // 清理
        try planTemplateService.deleteTemplate(template1)
        try categoryService.deleteCategory(category)
    }
    
    func testCreatePlanTemplateWithInvalidPriority() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 尝试创建优先级小于1的模板
        XCTAssertThrowsError(try planTemplateService.createTemplate(
            name: "无效优先级",
            category: category,
            color: nil,
            isFixedTime: false,
            isReminderEnabled: false,
            reminderTime: nil,
            priority: 0,
            difficulty: 1,
            tags: nil
        )) { error in
            XCTAssertEqual(error as? PlanTemplateError, .invalidPriority)
        }
        
        // 尝试创建优先级大于5的模板
        XCTAssertThrowsError(try planTemplateService.createTemplate(
            name: "无效优先级",
            category: category,
            color: nil,
            isFixedTime: false,
            isReminderEnabled: false,
            reminderTime: nil,
            priority: 6,
            difficulty: 1,
            tags: nil
        )) { error in
            XCTAssertEqual(error as? PlanTemplateError, .invalidPriority)
        }
        
        // 清理
        try categoryService.deleteCategory(category)
    }
    
    func testCreatePlanTemplateWithInvalidDifficulty() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 尝试创建难度小于1的模板
        XCTAssertThrowsError(try planTemplateService.createTemplate(
            name: "无效难度",
            category: category,
            color: nil,
            isFixedTime: false,
            isReminderEnabled: false,
            reminderTime: nil,
            priority: 1,
            difficulty: 0,
            tags: nil
        )) { error in
            XCTAssertEqual(error as? PlanTemplateError, .invalidDifficulty)
        }
        
        // 尝试创建难度大于5的模板
        XCTAssertThrowsError(try planTemplateService.createTemplate(
            name: "无效难度",
            category: category,
            color: nil,
            isFixedTime: false,
            isReminderEnabled: false,
            reminderTime: nil,
            priority: 1,
            difficulty: 6,
            tags: nil
        )) { error in
            XCTAssertEqual(error as? PlanTemplateError, .invalidDifficulty)
        }
        
        // 清理
        try categoryService.deleteCategory(category)
    }
    
    // MARK: - 查询测试
    
    func testFetchPlanTemplatesByCategory() throws {
        // 创建类别
        let category1 = try categoryService.createCategory(name: "类别1", color: "#FF0000", parent: nil)
        let category2 = try categoryService.createCategory(name: "类别2", color: "#00FF00", parent: nil)
        
        // 创建模板
        let template1 = try planTemplateService.createTemplate(
            name: "模板1",
            category: category1,
            color: nil,
            isFixedTime: false,
            isReminderEnabled: false,
            reminderTime: nil,
            priority: 1,
            difficulty: 1,
            tags: nil
        )
        
        let template2 = try planTemplateService.createTemplate(
            name: "模板2",
            category: category1,
            color: nil,
            isFixedTime: true,
            isReminderEnabled: false,
            reminderTime: nil,
            priority: 2,
            difficulty: 2,
            tags: nil
        )
        
        let template3 = try planTemplateService.createTemplate(
            name: "模板3",
            category: category2,
            color: nil,
            isFixedTime: false,
            isReminderEnabled: false,
            reminderTime: nil,
            priority: 3,
            difficulty: 3,
            tags: nil
        )
        
        // 查询类别1的模板
        let templatesInCategory1 = try planTemplateService.fetchTemplates(in: category1)
        XCTAssertEqual(templatesInCategory1.count, 2, "类别1应该有2个模板")
        XCTAssertTrue(templatesInCategory1.contains(template1), "类别1应该包含模板1")
        XCTAssertTrue(templatesInCategory1.contains(template2), "类别1应该包含模板2")
        
        // 查询类别2的模板
        let templatesInCategory2 = try planTemplateService.fetchTemplates(in: category2)
        XCTAssertEqual(templatesInCategory2.count, 1, "类别2应该有1个模板")
        XCTAssertTrue(templatesInCategory2.contains(template3), "类别2应该包含模板3")
        
        // 清理
        try planTemplateService.deleteTemplate(template1)
        try planTemplateService.deleteTemplate(template2)
        try planTemplateService.deleteTemplate(template3)
        try categoryService.deleteCategory(category1)
        try categoryService.deleteCategory(category2)
    }
    
    func testFetchPlanTemplatesByPriority() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 创建不同优先级的模板
        let template1 = try planTemplateService.createPlanTemplate(
            name: "低优先级",
            category: category,
            priority: 0,
            difficulty: 1,
            isFixedTime: false,
            color: nil,
            description: nil
        )
        
        let template2 = try planTemplateService.createPlanTemplate(
            name: "中优先级",
            category: category,
            priority: 1,
            difficulty: 1,
            isFixedTime: false,
            color: nil,
            description: nil
        )
        
        let template3 = try planTemplateService.createPlanTemplate(
            name: "高优先级",
            category: category,
            priority: 2,
            difficulty: 1,
            isFixedTime: false,
            color: nil,
            description: nil
        )
        
        // 获取高优先级模板
        let highPriorityTemplates = try planTemplateService.fetchPlanTemplates(withPriority: 2)
        
        XCTAssertEqual(highPriorityTemplates.count, 1, "应该有一个高优先级模板")
        XCTAssertTrue(highPriorityTemplates.contains(template3), "高优先级模板应该在结果中")
        
        // 清理
        try planTemplateService.deletePlanTemplate(template1)
        try planTemplateService.deletePlanTemplate(template2)
        try planTemplateService.deletePlanTemplate(template3)
        try categoryService.deleteCategory(category)
    }
    
    func testFetchAllPlanTemplates() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 创建模板
        let template1 = try planTemplateService.createTemplate(
            name: "模板1",
            category: category,
            color: nil,
            isFixedTime: false,
            isReminderEnabled: false,
            reminderTime: nil,
            priority: 1,
            difficulty: 1,
            tags: nil
        )
        
        let template2 = try planTemplateService.createTemplate(
            name: "模板2",
            category: nil,
            color: nil,
            isFixedTime: true,
            isReminderEnabled: false,
            reminderTime: nil,
            priority: 2,
            difficulty: 2,
            tags: nil
        )
        
        // 获取所有模板
        let allTemplates = try planTemplateService.fetchAllTemplates()
        XCTAssertEqual(allTemplates.count, 2, "应该有2个模板")
        XCTAssertTrue(allTemplates.contains(template1), "结果应该包含模板1")
        XCTAssertTrue(allTemplates.contains(template2), "结果应该包含模板2")
        
        // 清理
        try planTemplateService.deleteTemplate(template1)
        try planTemplateService.deleteTemplate(template2)
        try categoryService.deleteCategory(category)
    }
    
    // MARK: - 更新测试
    
    func testUpdatePlanTemplate() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 创建模板
        let template = try planTemplateService.createPlanTemplate(
            name: "原始名称",
            category: category,
            priority: 1,
            difficulty: 1,
            isFixedTime: false,
            color: "#000000",
            description: "原描述"
        )
        
        // 更新模板
        try planTemplateService.updatePlanTemplate(
            template,
            name: "新名称",
            priority: 2,
            difficulty: 2,
            isFixedTime: true,
            color: "#FFFFFF",
            description: "新描述"
        )
        
        XCTAssertEqual(template.name, "新名称", "模板名称应该已更新")
        XCTAssertEqual(template.priority, 2, "模板优先级应该已更新")
        XCTAssertEqual(template.difficulty, 2, "模板难度应该已更新")
        XCTAssertTrue(template.isFixedTime, "模板固定时间标志应该已更新")
        XCTAssertEqual(template.color, "#FFFFFF", "模板颜色应该已更新")
        XCTAssertEqual(template.templateDescription, "新描述", "模板描述应该已更新")
        
        // 清理
        try planTemplateService.deletePlanTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    func testUpdatePlanTemplateWithDuplicateName() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 创建两个模板
        let template1 = try planTemplateService.createPlanTemplate(
            name: "模板1",
            category: category,
            priority: 1,
            difficulty: 1,
            isFixedTime: false,
            color: nil,
            description: nil
        )
        
        let template2 = try planTemplateService.createPlanTemplate(
            name: "模板2",
            category: category,
            priority: 2,
            difficulty: 2,
            isFixedTime: true,
            color: nil,
            description: nil
        )
        
        // 尝试将模板2的名称更新为模板1的名称
        XCTAssertThrowsError(try planTemplateService.updatePlanTemplate(
            template2,
            name: "模板1",
            priority: 2,
            difficulty: 2,
            isFixedTime: true,
            color: nil,
            description: nil
        )) { error in
            XCTAssertEqual(error as? PlanTemplateError, .nameAlreadyExists)
        }
        
        // 清理
        try planTemplateService.deletePlanTemplate(template1)
        try planTemplateService.deletePlanTemplate(template2)
        try categoryService.deleteCategory(category)
    }
    
    // MARK: - 删除测试
    
    func testDeletePlanTemplate() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 创建模板
        let template = try planTemplateService.createTemplate(
            name: "测试模板",
            category: category,
            color: nil,
            isFixedTime: false,
            isReminderEnabled: false,
            reminderTime: nil,
            priority: 1,
            difficulty: 1,
            tags: nil
        )
        
        // 删除模板
        try planTemplateService.deleteTemplate(template)
        
        // 验证模板被软删除
        let deletedTemplates = try planTemplateService.fetchAllTemplates()
        XCTAssertEqual(deletedTemplates.count, 0, "不应该有任何可见的模板")
        
        // 清理
        try categoryService.deleteCategory(category)
    }
} 