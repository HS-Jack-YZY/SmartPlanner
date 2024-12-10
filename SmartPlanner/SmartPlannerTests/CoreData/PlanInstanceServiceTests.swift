//
//  PlanInstanceServiceTests.swift
//  SmartPlannerTests
//
//  Created by HS_Jack_YZY on 2024/12/11.
//

import XCTest
import CoreData
@testable import SmartPlanner

final class PlanInstanceServiceTests: XCTestCase {
    
    var planInstanceService: PlanInstanceService!
    var planTemplateService: PlanTemplateService!
    var categoryService: CategoryService!
    var coreDataManager: CoreDataManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataManager = CoreDataManager.shared
        categoryService = CategoryService(coreDataManager: coreDataManager)
        planTemplateService = PlanTemplateService(coreDataManager: coreDataManager)
        planInstanceService = PlanInstanceService(coreDataManager: coreDataManager)
    }
    
    override func tearDownWithError() throws {
        planInstanceService = nil
        planTemplateService = nil
        categoryService = nil
        coreDataManager = nil
        try super.tearDownWithError()
    }
    
    // MARK: - 创建测试
    
    func testCreatePlanInstance() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planTemplateService.createPlanTemplate(
            name: "测试计划模板",
            category: category,
            priority: 1,
            difficulty: 2,
            isFixedTime: false,
            color: "#00FF00",
            description: "测试描述"
        )
        
        // 创建计划实例
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600)
        let instance = try planInstanceService.createPlanInstance(
            template: template,
            startTime: startTime,
            endTime: endTime,
            priority: 2,
            difficulty: 1,
            isCompleted: false,
            shouldRemind: true,
            remindTime: startTime.addingTimeInterval(-900) // 提前15分钟提醒
        )
        
        XCTAssertNotNil(instance.id, "实例ID不应为空")
        XCTAssertEqual(instance.template, template, "实例模板应该匹配")
        XCTAssertEqual(instance.startTime, startTime, "实例开始时间应该匹配")
        XCTAssertEqual(instance.endTime, endTime, "实例结束时间应该匹配")
        XCTAssertEqual(instance.priority, 2, "实例优先级应该匹配")
        XCTAssertEqual(instance.difficulty, 1, "实例难度应该匹配")
        XCTAssertFalse(instance.isCompleted, "实例完成状态应该匹配")
        XCTAssertTrue(instance.shouldRemind, "实例提醒标志应该匹配")
        XCTAssertEqual(instance.remindTime, startTime.addingTimeInterval(-900), "实例提醒时间应该匹配")
        XCTAssertTrue(instance.isVisible, "实例默认应该可见")
        
        // 清理
        try planInstanceService.deletePlanInstance(instance)
        try planTemplateService.deletePlanTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    func testCreatePlanInstanceWithInvalidTimeRange() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planTemplateService.createPlanTemplate(
            name: "测试计划模板",
            category: category,
            priority: 1,
            difficulty: 1,
            isFixedTime: false,
            color: nil,
            description: nil
        )
        
        // 尝试创建结束时间早于开始时间的实例
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(-3600) // 负时间间隔
        
        XCTAssertThrowsError(try planInstanceService.createPlanInstance(
            template: template,
            startTime: startTime,
            endTime: endTime,
            priority: 1,
            difficulty: 1,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )) { error in
            XCTAssertEqual(error as? PlanInstanceError, .invalidTimeRange)
        }
        
        // 清理
        try planTemplateService.deletePlanTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    func testCreatePlanInstanceWithInvalidPriority() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planTemplateService.createPlanTemplate(
            name: "测试计划模版",
            category: category,
            priority: 1,
            difficulty: 1,
            isFixedTime: false,
            color: nil,
            description: nil
        )
        
        // 尝试创建优先级小于0的实例
        XCTAssertThrowsError(try planInstanceService.createPlanInstance(
            template: template,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            priority: -1,
            difficulty: 1,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )) { error in
            XCTAssertEqual(error as? PlanInstanceError, .invalidPriority)
        }
        
        // 尝试创建优先级大于3的实例
        XCTAssertThrowsError(try planInstanceService.createPlanInstance(
            template: template,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            priority: 4,
            difficulty: 1,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )) { error in
            XCTAssertEqual(error as? PlanInstanceError, .invalidPriority)
        }
        
        // 清理
        try planTemplateService.deletePlanTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    func testCreatePlanInstanceWithInvalidDifficulty() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planTemplateService.createPlanTemplate(
            name: "测试计划模版",
            category: category,
            priority: 1,
            difficulty: 1,
            isFixedTime: false,
            color: nil,
            description: nil
        )
        
        // 尝试创建难度小于0的实例
        XCTAssertThrowsError(try planInstanceService.createPlanInstance(
            template: template,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            priority: 1,
            difficulty: -1,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )) { error in
            XCTAssertEqual(error as? PlanInstanceError, .invalidDifficulty)
        }
        
        // 尝试创建难度大于3的实例
        XCTAssertThrowsError(try planInstanceService.createPlanInstance(
            template: template,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            priority: 1,
            difficulty: 4,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )) { error in
            XCTAssertEqual(error as? PlanInstanceError, .invalidDifficulty)
        }
        
        // 清理
        try planTemplateService.deletePlanTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    func testCreatePlanInstanceWithInvalidRemindTime() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planTemplateService.createPlanTemplate(
            name: "测试计划模版",
            category: category,
            priority: 1,
            difficulty: 1,
            isFixedTime: false,
            color: nil,
            description: nil
        )
        
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600)
        
        // 尝试创建提醒时间晚于开始时间的实例
        XCTAssertThrowsError(try planInstanceService.createPlanInstance(
            template: template,
            startTime: startTime,
            endTime: endTime,
            priority: 1,
            difficulty: 1,
            isCompleted: false,
            shouldRemind: true,
            remindTime: startTime.addingTimeInterval(300) // 提醒时间晚于开始时间
        )) { error in
            XCTAssertEqual(error as? PlanInstanceError, .invalidRemindTime)
        }
        
        // 清理
        try planTemplateService.deletePlanTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    // MARK: - 查询测试
    
    func testFetchPlanInstancesByTimeRange() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planTemplateService.createPlanTemplate(
            name: "测试计划模版",
            category: category,
            priority: 1,
            difficulty: 1,
            isFixedTime: false,
            color: nil,
            description: nil
        )
        
        // 创建三个实例，时间依次递增
        let baseTime = Date()
        let instance1 = try planInstanceService.createPlanInstance(
            template: template,
            startTime: baseTime,
            endTime: baseTime.addingTimeInterval(3600),
            priority: 1,
            difficulty: 1,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )
        
        let instance2 = try planInstanceService.createPlanInstance(
            template: template,
            startTime: baseTime.addingTimeInterval(7200),
            endTime: baseTime.addingTimeInterval(10800),
            priority: 2,
            difficulty: 2,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )
        
        let instance3 = try planInstanceService.createPlanInstance(
            template: template,
            startTime: baseTime.addingTimeInterval(14400),
            endTime: baseTime.addingTimeInterval(18000),
            priority: 3,
            difficulty: 3,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )
        
        // 查询中间时间段的实例
        let searchStart = baseTime.addingTimeInterval(3600)
        let searchEnd = baseTime.addingTimeInterval(14400)
        let instances = try planInstanceService.fetchPlanInstances(
            from: searchStart,
            to: searchEnd
        )
        
        XCTAssertEqual(instances.count, 1, "应该只有一个实例在查询时间范围内")
        XCTAssertTrue(instances.contains(instance2), "中间的实例应该在结果中")
        XCTAssertFalse(instances.contains(instance1), "第一个实例不应该在结果中")
        XCTAssertFalse(instances.contains(instance3), "第三个实例不应该在结果中")
        
        // 清理
        try planInstanceService.deletePlanInstance(instance1)
        try planInstanceService.deletePlanInstance(instance2)
        try planInstanceService.deletePlanInstance(instance3)
        try planTemplateService.deletePlanTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    func testFetchPlanInstancesByTemplate() throws {
        // 创建类别和两个模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
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
        
        // 为每个模板创建实例
        let baseTime = Date()
        let instance1 = try planInstanceService.createPlanInstance(
            template: template1,
            startTime: baseTime,
            endTime: baseTime.addingTimeInterval(3600),
            priority: 1,
            difficulty: 1,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )
        
        let instance2 = try planInstanceService.createPlanInstance(
            template: template1,
            startTime: baseTime.addingTimeInterval(7200),
            endTime: baseTime.addingTimeInterval(10800),
            priority: 2,
            difficulty: 2,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )
        
        let instance3 = try planInstanceService.createPlanInstance(
            template: template2,
            startTime: baseTime.addingTimeInterval(14400),
            endTime: baseTime.addingTimeInterval(18000),
            priority: 3,
            difficulty: 3,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )
        
        // 查询模板1的实例
        let instancesOfTemplate1 = try planInstanceService.fetchPlanInstances(
            fromTemplate: template1
        )
        
        XCTAssertEqual(instancesOfTemplate1.count, 2, "模板1应该有两个实例")
        XCTAssertTrue(instancesOfTemplate1.contains(instance1), "实例1应该在结果中")
        XCTAssertTrue(instancesOfTemplate1.contains(instance2), "实例2应该在结果中")
        XCTAssertFalse(instancesOfTemplate1.contains(instance3), "实例3不应该在结果中")
        
        // 清理
        try planInstanceService.deletePlanInstance(instance1)
        try planInstanceService.deletePlanInstance(instance2)
        try planInstanceService.deletePlanInstance(instance3)
        try planTemplateService.deletePlanTemplate(template1)
        try planTemplateService.deletePlanTemplate(template2)
        try categoryService.deleteCategory(category)
    }
    
    func testFetchPlanInstancesByPriority() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planTemplateService.createPlanTemplate(
            name: "测试计划模板",
            category: category,
            priority: 1,
            difficulty: 1,
            isFixedTime: false,
            color: nil,
            description: nil
        )
        
        // 创建不同优先级的实例
        let baseTime = Date()
        let instance1 = try planInstanceService.createPlanInstance(
            template: template,
            startTime: baseTime,
            endTime: baseTime.addingTimeInterval(3600),
            priority: 0,
            difficulty: 1,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )
        
        let instance2 = try planInstanceService.createPlanInstance(
            template: template,
            startTime: baseTime.addingTimeInterval(7200),
            endTime: baseTime.addingTimeInterval(10800),
            priority: 1,
            difficulty: 1,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )
        
        let instance3 = try planInstanceService.createPlanInstance(
            template: template,
            startTime: baseTime.addingTimeInterval(14400),
            endTime: baseTime.addingTimeInterval(18000),
            priority: 2,
            difficulty: 1,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )
        
        // 查询高优先级实例
        let highPriorityInstances = try planInstanceService.fetchPlanInstances(
            withPriority: 2
        )
        
        XCTAssertEqual(highPriorityInstances.count, 1, "应该有一个高优先级实例")
        XCTAssertTrue(highPriorityInstances.contains(instance3), "高优先级实例应该在结果中")
        
        // 清理
        try planInstanceService.deletePlanInstance(instance1)
        try planInstanceService.deletePlanInstance(instance2)
        try planInstanceService.deletePlanInstance(instance3)
        try planTemplateService.deletePlanTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    // MARK: - 更新测试
    
    func testUpdatePlanInstance() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planTemplateService.createPlanTemplate(
            name: "测试计划模板",
            category: category,
            priority: 1,
            difficulty: 1,
            isFixedTime: false,
            color: nil,
            description: nil
        )
        
        // 创建实例
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600)
        let instance = try planInstanceService.createPlanInstance(
            template: template,
            startTime: startTime,
            endTime: endTime,
            priority: 1,
            difficulty: 1,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )
        
        // 更新实例
        let newStartTime = startTime.addingTimeInterval(7200)
        let newEndTime = newStartTime.addingTimeInterval(3600)
        let newRemindTime = newStartTime.addingTimeInterval(-900)
        try planInstanceService.updatePlanInstance(
            instance,
            startTime: newStartTime,
            endTime: newEndTime,
            priority: 2,
            difficulty: 2,
            isCompleted: true,
            shouldRemind: true,
            remindTime: newRemindTime
        )
        
        XCTAssertEqual(instance.startTime, newStartTime, "实例开始时间应该已更新")
        XCTAssertEqual(instance.endTime, newEndTime, "实例结束时间应该已更新")
        XCTAssertEqual(instance.priority, 2, "��例优先级应该已更新")
        XCTAssertEqual(instance.difficulty, 2, "实例难度应该已更新")
        XCTAssertTrue(instance.isCompleted, "实例完成状态应该已更新")
        XCTAssertTrue(instance.shouldRemind, "实例提醒标志应该已更新")
        XCTAssertEqual(instance.remindTime, newRemindTime, "实例提醒时间应该已更新")
        
        // 清理
        try planInstanceService.deletePlanInstance(instance)
        try planTemplateService.deletePlanTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    // MARK: - 删除测试
    
    func testDeletePlanInstance() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planTemplateService.createPlanTemplate(
            name: "测试计划模板",
            category: category,
            priority: 1,
            difficulty: 1,
            isFixedTime: false,
            color: nil,
            description: nil
        )
        
        // 创建实例
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600)
        let instance = try planInstanceService.createPlanInstance(
            template: template,
            startTime: startTime,
            endTime: endTime,
            priority: 1,
            difficulty: 1,
            isCompleted: false,
            shouldRemind: false,
            remindTime: nil
        )
        
        // 删除实例
        try planInstanceService.deletePlanInstance(instance)
        
        // 验证实例被软删除
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: "deletedAt != nil")
        let deletedInstances = try coreDataManager.fetch(PlanInstance.self,
                                                       predicate: predicate,
                                                       context: context)
        
        XCTAssertEqual(deletedInstances.count, 1, "应该有一个被软删除的实例")
        XCTAssertTrue(deletedInstances.contains(instance), "测试实例应该被软删除")
        
        // 清理
        context.delete(instance)
        try planTemplateService.deletePlanTemplate(template)
        try categoryService.deleteCategory(category)
        try coreDataManager.saveContext(context)
    }
} 