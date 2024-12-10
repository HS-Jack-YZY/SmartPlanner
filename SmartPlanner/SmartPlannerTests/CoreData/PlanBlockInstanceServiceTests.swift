//
//  PlanBlockInstanceServiceTests.swift
//  SmartPlannerTests
//
//  Created by HS_Jack_YZY on 2024/12/11.
//

import XCTest
import CoreData
@testable import SmartPlanner

final class PlanBlockInstanceServiceTests: XCTestCase {
    
    var planBlockInstanceService: PlanBlockInstanceService!
    var planBlockTemplateService: PlanBlockTemplateService!
    var categoryService: CategoryService!
    var coreDataManager: CoreDataManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataManager = CoreDataManager.shared
        categoryService = CategoryService(coreDataManager: coreDataManager)
        planBlockTemplateService = PlanBlockTemplateService(coreDataManager: coreDataManager)
        planBlockInstanceService = PlanBlockInstanceService(coreDataManager: coreDataManager)
    }
    
    override func tearDownWithError() throws {
        planBlockInstanceService = nil
        planBlockTemplateService = nil
        categoryService = nil
        coreDataManager = nil
        try super.tearDownWithError()
    }
    
    // MARK: - 创建测试
    
    func testCreatePlanBlockInstance() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planBlockTemplateService.createPlanBlockTemplate(
            name: "测试区间模板",
            category: category,
            duration: 3600,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        // 创建计划区间实例
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600)
        let instance = try planBlockInstanceService.createPlanBlockInstance(
            template: template,
            startTime: startTime,
            endTime: endTime,
            isCompleted: false
        )
        
        XCTAssertNotNil(instance.id, "实例ID不应为空")
        XCTAssertEqual(instance.template, template, "实例模板应该匹配")
        XCTAssertEqual(instance.startTime, startTime, "实例开始时间应该匹配")
        XCTAssertEqual(instance.endTime, endTime, "实例结束时间应该匹配")
        XCTAssertFalse(instance.isCompleted, "实例完成状态应该匹配")
        XCTAssertTrue(instance.isVisible, "实例默认应该可见")
        
        // 清理
        try planBlockInstanceService.deletePlanBlockInstance(instance)
        try planBlockTemplateService.deletePlanBlockTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    func testCreatePlanBlockInstanceWithInvalidTimeRange() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planBlockTemplateService.createPlanBlockTemplate(
            name: "测试区间模板",
            category: category,
            duration: 3600,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        // 尝试创建结束时间早于开始时间的实例
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(-3600) // 负时间间隔
        
        XCTAssertThrowsError(try planBlockInstanceService.createPlanBlockInstance(
            template: template,
            startTime: startTime,
            endTime: endTime,
            isCompleted: false
        )) { error in
            XCTAssertEqual(error as? PlanBlockInstanceError, .invalidTimeRange)
        }
        
        // 清理
        try planBlockTemplateService.deletePlanBlockTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    func testCreatePlanBlockInstanceWithTimeConflict() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planBlockTemplateService.createPlanBlockTemplate(
            name: "测试区间模板",
            category: category,
            duration: 3600,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        // 创建第一个实例
        let startTime1 = Date()
        let endTime1 = startTime1.addingTimeInterval(3600)
        let instance1 = try planBlockInstanceService.createPlanBlockInstance(
            template: template,
            startTime: startTime1,
            endTime: endTime1,
            isCompleted: false
        )
        
        // 尝试创建时间重叠的第二个实例
        let startTime2 = startTime1.addingTimeInterval(1800) // 重叠1800秒
        let endTime2 = endTime1.addingTimeInterval(1800)
        
        XCTAssertThrowsError(try planBlockInstanceService.createPlanBlockInstance(
            template: template,
            startTime: startTime2,
            endTime: endTime2,
            isCompleted: false
        )) { error in
            XCTAssertEqual(error as? PlanBlockInstanceError, .timeConflict)
        }
        
        // 清理
        try planBlockInstanceService.deletePlanBlockInstance(instance1)
        try planBlockTemplateService.deletePlanBlockTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    // MARK: - 查询测试
    
    func testFetchPlanBlockInstancesByTimeRange() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planBlockTemplateService.createPlanBlockTemplate(
            name: "测试区间模板",
            category: category,
            duration: 3600,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        // 创建三个实例，时间依次递增
        let baseTime = Date()
        let instance1 = try planBlockInstanceService.createPlanBlockInstance(
            template: template,
            startTime: baseTime,
            endTime: baseTime.addingTimeInterval(3600),
            isCompleted: false
        )
        
        let instance2 = try planBlockInstanceService.createPlanBlockInstance(
            template: template,
            startTime: baseTime.addingTimeInterval(7200),
            endTime: baseTime.addingTimeInterval(10800),
            isCompleted: false
        )
        
        let instance3 = try planBlockInstanceService.createPlanBlockInstance(
            template: template,
            startTime: baseTime.addingTimeInterval(14400),
            endTime: baseTime.addingTimeInterval(18000),
            isCompleted: false
        )
        
        // 查询中间时间段的实例
        let searchStart = baseTime.addingTimeInterval(3600)
        let searchEnd = baseTime.addingTimeInterval(14400)
        let instances = try planBlockInstanceService.fetchPlanBlockInstances(
            from: searchStart,
            to: searchEnd
        )
        
        XCTAssertEqual(instances.count, 1, "应该只有一个实例在查询时间范围内")
        XCTAssertTrue(instances.contains(instance2), "中间的实例应该在结果中")
        XCTAssertFalse(instances.contains(instance1), "第一个实例不应该在结果中")
        XCTAssertFalse(instances.contains(instance3), "第三个实例不应该在结果中")
        
        // 清理
        try planBlockInstanceService.deletePlanBlockInstance(instance1)
        try planBlockInstanceService.deletePlanBlockInstance(instance2)
        try planBlockInstanceService.deletePlanBlockInstance(instance3)
        try planBlockTemplateService.deletePlanBlockTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    func testFetchPlanBlockInstancesByTemplate() throws {
        // 创建类别和两个模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
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
        
        // 为每个模板创建实例
        let baseTime = Date()
        let instance1 = try planBlockInstanceService.createPlanBlockInstance(
            template: template1,
            startTime: baseTime,
            endTime: baseTime.addingTimeInterval(3600),
            isCompleted: false
        )
        
        let instance2 = try planBlockInstanceService.createPlanBlockInstance(
            template: template1,
            startTime: baseTime.addingTimeInterval(7200),
            endTime: baseTime.addingTimeInterval(10800),
            isCompleted: false
        )
        
        let instance3 = try planBlockInstanceService.createPlanBlockInstance(
            template: template2,
            startTime: baseTime.addingTimeInterval(14400),
            endTime: baseTime.addingTimeInterval(21600),
            isCompleted: false
        )
        
        // 查询模板1的实例
        let instancesOfTemplate1 = try planBlockInstanceService.fetchPlanBlockInstances(
            fromTemplate: template1
        )
        
        XCTAssertEqual(instancesOfTemplate1.count, 2, "模板1应该有两个实例")
        XCTAssertTrue(instancesOfTemplate1.contains(instance1), "实例1应该在结果中")
        XCTAssertTrue(instancesOfTemplate1.contains(instance2), "实例2应该在结果中")
        XCTAssertFalse(instancesOfTemplate1.contains(instance3), "实例3不应该在结果中")
        
        // 清理
        try planBlockInstanceService.deletePlanBlockInstance(instance1)
        try planBlockInstanceService.deletePlanBlockInstance(instance2)
        try planBlockInstanceService.deletePlanBlockInstance(instance3)
        try planBlockTemplateService.deletePlanBlockTemplate(template1)
        try planBlockTemplateService.deletePlanBlockTemplate(template2)
        try categoryService.deleteCategory(category)
    }
    
    // MARK: - 更新测试
    
    func testUpdatePlanBlockInstance() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planBlockTemplateService.createPlanBlockTemplate(
            name: "测试区间模板",
            category: category,
            duration: 3600,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        // 创建实例
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600)
        let instance = try planBlockInstanceService.createPlanBlockInstance(
            template: template,
            startTime: startTime,
            endTime: endTime,
            isCompleted: false
        )
        
        // 更新实例
        let newStartTime = startTime.addingTimeInterval(7200)
        let newEndTime = newStartTime.addingTimeInterval(3600)
        try planBlockInstanceService.updatePlanBlockInstance(
            instance,
            startTime: newStartTime,
            endTime: newEndTime,
            isCompleted: true
        )
        
        XCTAssertEqual(instance.startTime, newStartTime, "实例开始时间应该已更新")
        XCTAssertEqual(instance.endTime, newEndTime, "实例结束时间应���已更新")
        XCTAssertTrue(instance.isCompleted, "实例完成状态应该已更新")
        
        // 清理
        try planBlockInstanceService.deletePlanBlockInstance(instance)
        try planBlockTemplateService.deletePlanBlockTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    func testUpdatePlanBlockInstanceWithTimeConflict() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planBlockTemplateService.createPlanBlockTemplate(
            name: "测试区间模板",
            category: category,
            duration: 3600,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        // 创建两个实例
        let startTime1 = Date()
        let endTime1 = startTime1.addingTimeInterval(3600)
        let instance1 = try planBlockInstanceService.createPlanBlockInstance(
            template: template,
            startTime: startTime1,
            endTime: endTime1,
            isCompleted: false
        )
        
        let startTime2 = startTime1.addingTimeInterval(7200)
        let endTime2 = startTime2.addingTimeInterval(3600)
        let instance2 = try planBlockInstanceService.createPlanBlockInstance(
            template: template,
            startTime: startTime2,
            endTime: endTime2,
            isCompleted: false
        )
        
        // 尝试更新instance2的时间使其与instance1冲突
        XCTAssertThrowsError(try planBlockInstanceService.updatePlanBlockInstance(
            instance2,
            startTime: startTime1.addingTimeInterval(1800),
            endTime: endTime1.addingTimeInterval(1800),
            isCompleted: false
        )) { error in
            XCTAssertEqual(error as? PlanBlockInstanceError, .timeConflict)
        }
        
        // 清理
        try planBlockInstanceService.deletePlanBlockInstance(instance1)
        try planBlockInstanceService.deletePlanBlockInstance(instance2)
        try planBlockTemplateService.deletePlanBlockTemplate(template)
        try categoryService.deleteCategory(category)
    }
    
    // MARK: - 删除测试
    
    func testDeletePlanBlockInstance() throws {
        // 创建类别和模板
        let category = try categoryService.createCategory(name: "测试类别", color: "#FF0000", parent: nil)
        let template = try planBlockTemplateService.createPlanBlockTemplate(
            name: "测试区间模板",
            category: category,
            duration: 3600,
            isFixedTime: false,
            preferredStartTime: nil,
            preferredEndTime: nil
        )
        
        // 创建实例
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600)
        let instance = try planBlockInstanceService.createPlanBlockInstance(
            template: template,
            startTime: startTime,
            endTime: endTime,
            isCompleted: false
        )
        
        // 删除实例
        try planBlockInstanceService.deletePlanBlockInstance(instance)
        
        // 验证实例被软删除
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: "deletedAt != nil")
        let deletedInstances = try coreDataManager.fetch(PlanBlockInstance.self,
                                                       predicate: predicate,
                                                       context: context)
        
        XCTAssertEqual(deletedInstances.count, 1, "应该有一个被软删除的实例")
        XCTAssertTrue(deletedInstances.contains(instance), "测试实例应该被软删除")
        
        // 清理
        context.delete(instance)
        try planBlockTemplateService.deletePlanBlockTemplate(template)
        try categoryService.deleteCategory(category)
        try coreDataManager.saveContext(context)
    }
} 