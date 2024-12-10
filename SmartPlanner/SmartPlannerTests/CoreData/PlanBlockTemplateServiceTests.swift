//
//  PlanBlockTemplateServiceTests.swift
//  SmartPlannerTests
//
//  Created by HS_Jack_YZY on 2024/12/11.
//

import XCTest
import CoreData
@testable import SmartPlanner

final class PlanBlockTemplateServiceTests: XCTestCase {
    
    var planBlockTemplateService: PlanBlockTemplateService!
    var categoryService: CategoryService!
    var coreDataManager: CoreDataManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataManager = CoreDataManager.shared
        categoryService = CategoryService(coreDataManager: coreDataManager)
        planBlockTemplateService = PlanBlockTemplateService(coreDataManager: coreDataManager)
    }
    
    override func tearDownWithError() throws {
        planBlockTemplateService = nil
        categoryService = nil
        coreDataManager = nil
        try super.tearDownWithError()
    }
    
    // MARK: - 创建测试
    
    func testCreatePlanBlockTemplate() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 创建计划区间模板
        let template = try planBlockTemplateService.createPlanBlockTemplate(
            name: "测试区间模板",
            category: category,
            duration: 3600, // 1小时
            isFixedTime: false,
            preferredStartTime: Date(timeIntervalSince1970: 32400), // 9:00 AM
            preferredEndTime: Date(timeIntervalSince1970: 61200)    // 5:00 PM
        )
        
        XCTAssertNotNil(template.id, "模板ID不应为空")
        XCTAssertEqual(template.name, "测试区间模板", "模板名称应该匹配")
        XCTAssertEqual(template.category, category, "模板类别应该匹配")
        XCTAssertEqual(template.duration, 3600, "模板持续时间应该匹配")
        XCTAssertFalse(template.isFixedTime, "模板固定时间标志应该匹配")
        XCTAssertEqual(template.preferredStartTime?.timeIntervalSince1970, 32400, "模板首选开始时间应该匹配")
        XCTAssertEqual(template.preferredEndTime?.timeIntervalSince1970, 61200, "模板首选结束时间应该匹配")
        XCTAssertTrue(template.isVisible, "模板默认应该可见")
        
        // 清理
        try planBlockTemplateService.deletePlanBlockTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    func testCreatePlanBlockTemplateWithDuplicateName() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 创建第一个模板
        let template1 = try planBlockTemplateService.createPlanBlockTemplate(
            name: "重复名称",
            category: category,
            duration: 3600,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        // 尝试创建同名模板
        XCTAssertThrowsError(try planBlockTemplateService.createPlanBlockTemplate(
            name: "重复名称",
            category: category,
            duration: 7200,
            isFixedTime: true,
            preferredStartTime: nil,
            preferredEndTime: nil
        )) { error in
            XCTAssertEqual(error as? PlanBlockTemplateError, .nameAlreadyExists)
        }
        
        // 清理
        try planBlockTemplateService.deletePlanBlockTemplate(template1)
        try categoryService.deleteCategory(category)
    }
    
    func testCreatePlanBlockTemplateWithInvalidDuration() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 尝试创建持续时间为0的模板
        XCTAssertThrowsError(try planBlockTemplateService.createPlanBlockTemplate(
            name: "��效持续时间",
            category: category,
            duration: 0,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )) { error in
            XCTAssertEqual(error as? PlanBlockTemplateError, .invalidDuration)
        }
        
        // 尝试创建持续时间为负数的模板
        XCTAssertThrowsError(try planBlockTemplateService.createPlanBlockTemplate(
            name: "负持续时间",
            category: category,
            duration: -3600,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )) { error in
            XCTAssertEqual(error as? PlanBlockTemplateError, .invalidDuration)
        }
        
        // 清理
        try categoryService.deleteCategory(category)
    }
    
    func testCreatePlanBlockTemplateWithInvalidTimeRange() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 尝试创建结束时间早于开始时间的模板
        XCTAssertThrowsError(try planBlockTemplateService.createPlanBlockTemplate(
            name: "无效时间范围",
            category: category,
            duration: 3600,
            isFixedTime: true,
            preferredStartTime: Date(timeIntervalSince1970: 61200), // 5:00 PM
            preferredEndTime: Date(timeIntervalSince1970: 32400)    // 9:00 AM
        )) { error in
            XCTAssertEqual(error as? PlanBlockTemplateError, .invalidTimeRange)
        }
        
        // 清理
        try categoryService.deleteCategory(category)
    }
    
    // MARK: - 查询测试
    
    func testFetchPlanBlockTemplatesByCategory() throws {
        // 创建类别
        let category1 = try categoryService.createCategory(name: "类别1", color: "#FF0000", parent: nil)
        let category2 = try categoryService.createCategory(name: "类别2", color: "#00FF00", parent: nil)
        
        // 创建模板
        let template1 = try planBlockTemplateService.createPlanBlockTemplate(
            name: "模板1",
            category: category1,
            duration: 3600,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        let template2 = try planBlockTemplateService.createPlanBlockTemplate(
            name: "模板2",
            category: category1,
            duration: 7200,
            isFixedTime: true,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        let template3 = try planBlockTemplateService.createPlanBlockTemplate(
            name: "模板3",
            category: category2,
            duration: 5400,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        // 获取类别1的模板
        let templatesInCategory1 = try planBlockTemplateService.fetchPlanBlockTemplates(in: category1)
        
        XCTAssertEqual(templatesInCategory1.count, 2, "类别1应该有两个模板")
        XCTAssertTrue(templatesInCategory1.contains(template1), "模板1应该在结果中")
        XCTAssertTrue(templatesInCategory1.contains(template2), "模板2应该在结果中")
        XCTAssertFalse(templatesInCategory1.contains(template3), "模板3不应该在结果中")
        
        // 获取类别2的模板
        let templatesInCategory2 = try planBlockTemplateService.fetchPlanBlockTemplates(in: category2)
        
        XCTAssertEqual(templatesInCategory2.count, 1, "类别2应该有一个模板")
        XCTAssertTrue(templatesInCategory2.contains(template3), "模板3应该在结果中")
        
        // 清理
        try planBlockTemplateService.deletePlanBlockTemplate(template1)
        try planBlockTemplateService.deletePlanBlockTemplate(template2)
        try planBlockTemplateService.deletePlanBlockTemplate(template3)
        try categoryService.deleteCategory(category1)
        try categoryService.deleteCategory(category2)
    }
    
    // MARK: - 更新测试
    
    func testUpdatePlanBlockTemplate() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 创建模板
        let template = try planBlockTemplateService.createPlanBlockTemplate(
            name: "原始名称",
            category: category,
            duration: 3600,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        // 更新模板
        try planBlockTemplateService.updatePlanBlockTemplate(
            template,
            name: "新名称",
            duration: 7200,
            isFixedTime: true,
            preferredStartTime: Date(timeIntervalSince1970: 32400),
            preferredEndTime: Date(timeIntervalSince1970: 61200)
        )
        
        XCTAssertEqual(template.name, "新名称", "模板名称应该已更新")
        XCTAssertEqual(template.duration, 7200, "模板持续时间应该已更新")
        XCTAssertTrue(template.isFixedTime, "模板固定时间标志应该已更新")
        XCTAssertEqual(template.preferredStartTime?.timeIntervalSince1970, 32400, "模板首选开始时间应该已更新")
        XCTAssertEqual(template.preferredEndTime?.timeIntervalSince1970, 61200, "模板首选结束时间应该已更新")
        
        // 清理
        try planBlockTemplateService.deletePlanBlockTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    func testUpdatePlanBlockTemplateWithDuplicateName() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 创建两个模板
        let template1 = try planBlockTemplateService.createPlanBlockTemplate(
            name: "模板1",
            category: category,
            duration: 3600,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        let template2 = try planBlockTemplateService.createPlanBlockTemplate(
            name: "模板2",
            category: category,
            duration: 7200,
            isFixedTime: true,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        // 尝试将模板2的名称更新为模板1的名称
        XCTAssertThrowsError(try planBlockTemplateService.updatePlanBlockTemplate(
            template2,
            name: "模板1",
            duration: 7200,
            isFixedTime: true,
            preferredStartTime: nil,
            preferredEndTime: nil
        )) { error in
            XCTAssertEqual(error as? PlanBlockTemplateError, .nameAlreadyExists)
        }
        
        // 清理
        try planBlockTemplateService.deletePlanBlockTemplate(template1)
        try planBlockTemplateService.deletePlanBlockTemplate(template2)
        try categoryService.deleteCategory(category)
    }
    
    // MARK: - 删除测试
    
    func testDeletePlanBlockTemplate() throws {
        // 创建类别
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        
        // 创建模板
        let template = try planBlockTemplateService.createPlanBlockTemplate(
            name: "测试模板",
            category: category,
            duration: 3600,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        // 删除模板
        try planBlockTemplateService.deletePlanBlockTemplate(template)
        
        // 验证模板被软删除
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: "deletedAt != nil")
        let deletedTemplates = try coreDataManager.fetch(PlanBlockTemplate.self,
                                                       predicate: predicate,
                                                       context: context)
        
        XCTAssertEqual(deletedTemplates.count, 1, "应该有一个被软删除的模板")
        XCTAssertTrue(deletedTemplates.contains(template), "测试模板应该被软删除")
        
        // 清理
        context.delete(template)
        try categoryService.deleteCategory(category)
        try coreDataManager.saveContext(context)
    }
} 