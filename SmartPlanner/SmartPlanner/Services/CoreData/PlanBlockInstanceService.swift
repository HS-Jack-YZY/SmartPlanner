//
//  PlanBlockInstanceService.swift
//  SmartPlanner
//
//  Created by HS_Jack_YZY on 2024/12/11.
//

import CoreData
import Foundation

/// PlanBlockInstance 服务协议
protocol PlanBlockInstanceServiceProtocol {
    /// 创建区间实例
    /// - Parameters:
    ///   - template: 区间模板
    ///   - startAt: 开始时间
    ///   - endAt: 结束时间
    /// - Returns: 创建的区间实例
    func createInstance(from template: PlanBlockTemplate,
                       startAt: Date,
                       endAt: Date) throws -> PlanBlockInstance
    
    /// 获取指定时间范围内的区间实例
    /// - Parameters:
    ///   - start: 开始时间
    ///   - end: 结束时间
    /// - Returns: 区间实例列表
    func fetchInstances(between start: Date, and end: Date) throws -> [PlanBlockInstance]
    
    /// 获取指定模板的所有区间实例
    /// - Parameter template: 区间模板
    /// - Returns: 区间实例列表
    func fetchInstances(of template: PlanBlockTemplate) throws -> [PlanBlockInstance]
    
    /// 获取指定区间实例中的所有计划实例
    /// - Parameter instance: 区间实例
    /// - Returns: 计划实例列表
    func fetchPlanInstances(in instance: PlanBlockInstance) throws -> [PlanInstance]
    
    /// 更新区间实例时间
    /// - Parameters:
    ///   - instance: 要更新的实例
    ///   - startAt: 新的开始时间（可选）
    ///   - endAt: 新的结束时间（可选）
    func updateInstanceTime(_ instance: PlanBlockInstance,
                          startAt: Date?,
                          endAt: Date?) throws
    
    /// 删除区间实例（软删除）
    /// - Parameter instance: 要删除的实例
    func deleteInstance(_ instance: PlanBlockInstance) throws
    
    /// 检查时间范围是否有冲突
    /// - Parameters:
    ///   - startAt: 开始时间
    ///   - endAt: 结束时间
    ///   - template: 区间模板
    ///   - excluding: 排除的实例（用于更新时）
    /// - Returns: 是否存在冲突
    func hasTimeConflict(startAt: Date,
                        endAt: Date,
                        template: PlanBlockTemplate,
                        excluding: PlanBlockInstance?) throws -> Bool
}

/// PlanBlockInstance 服务实现
final class PlanBlockInstanceService: PlanBlockInstanceServiceProtocol {
    /// CoreData 管理器
    private let coreDataManager: CoreDataManager
    
    /// 初始化方法
    /// - Parameter coreDataManager: CoreData 管理器实例
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - 创建操作
    
    func createInstance(from template: PlanBlockTemplate,
                       startAt: Date,
                       endAt: Date) throws -> PlanBlockInstance {
        // 验证时间
        guard endAt > startAt else {
            throw PlanBlockInstanceError.invalidTimeRange
        }
        
        // 检查时间冲突
        guard try !hasTimeConflict(startAt: startAt,
                                 endAt: endAt,
                                 template: template,
                                 excluding: nil) else {
            throw PlanBlockInstanceError.timeConflict
        }
        
        let context = coreDataManager.mainContext
        let instance = coreDataManager.create(PlanBlockInstance.self, context: context)
        
        // 设置基本属性
        instance.id = UUID()
        instance.startAt = startAt
        instance.endAt = endAt
        instance.createdAt = Date()
        instance.updatedAt = Date()
        instance.blockTemplate = template
        
        try coreDataManager.saveContext(context)
        return instance
    }
    
    // MARK: - 查询操作
    
    func fetchInstances(between start: Date, and end: Date) throws -> [PlanBlockInstance] {
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: """
            (startAt <= %@ AND endAt >= %@) OR
            (startAt >= %@ AND startAt <= %@) OR
            (endAt >= %@ AND endAt <= %@) AND
            deletedAt == nil
            """,
            end as NSDate, start as NSDate,
            start as NSDate, end as NSDate,
            start as NSDate, end as NSDate)
        
        return try coreDataManager.fetch(PlanBlockInstance.self,
                                       predicate: predicate,
                                       context: context)
    }
    
    func fetchInstances(of template: PlanBlockTemplate) throws -> [PlanBlockInstance] {
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: "blockTemplate == %@ AND deletedAt == nil",
                                  template)
        return try coreDataManager.fetch(PlanBlockInstance.self,
                                       predicate: predicate,
                                       context: context)
    }
    
    func fetchPlanInstances(in instance: PlanBlockInstance) throws -> [PlanInstance] {
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: "blockInstance == %@ AND deletedAt == nil",
                                  instance)
        return try coreDataManager.fetch(PlanInstance.self,
                                       predicate: predicate,
                                       context: context)
    }
    
    // MARK: - 更新操作
    
    func updateInstanceTime(_ instance: PlanBlockInstance,
                          startAt: Date?,
                          endAt: Date?) throws {
        let newStartAt = startAt ?? instance.startAt!
        let newEndAt = endAt ?? instance.endAt!
        
        // 验证时间
        guard newEndAt > newStartAt else {
            throw PlanBlockInstanceError.invalidTimeRange
        }
        
        // 检查时间冲突
        guard try !hasTimeConflict(startAt: newStartAt,
                                 endAt: newEndAt,
                                 template: instance.blockTemplate!,
                                 excluding: instance) else {
            throw PlanBlockInstanceError.timeConflict
        }
        
        // 验证所有计划实例的时间是否仍在区间范围内
        let planInstances = try fetchPlanInstances(in: instance)
        for planInstance in planInstances {
            guard planInstance.startTime! >= newStartAt &&
                    planInstance.endTime! <= newEndAt else {
                throw PlanBlockInstanceError.planInstanceOutOfRange
            }
        }
        
        if let startAt = startAt {
            instance.startAt = startAt
        }
        
        if let endAt = endAt {
            instance.endAt = endAt
        }
        
        instance.updatedAt = Date()
        
        try coreDataManager.saveContext(coreDataManager.mainContext)
    }
    
    // MARK: - 删除操作
    
    func deleteInstance(_ instance: PlanBlockInstance) throws {
        let context = coreDataManager.mainContext
        try coreDataManager.delete(instance, context: context)
    }
    
    // MARK: - 验证方法
    
    func hasTimeConflict(startAt: Date,
                        endAt: Date,
                        template: PlanBlockTemplate,
                        excluding: PlanBlockInstance?) throws -> Bool {
        let context = coreDataManager.mainContext
        var predicateFormat = """
            blockTemplate == %@ AND
            ((startAt <= %@ AND endAt >= %@) OR
             (startAt >= %@ AND startAt <= %@) OR
             (endAt >= %@ AND endAt <= %@)) AND
            deletedAt == nil
            """
        var predicateArgs: [Any] = [
            template,
            endAt as NSDate, startAt as NSDate,
            startAt as NSDate, endAt as NSDate,
            startAt as NSDate, endAt as NSDate
        ]
        
        if let excluding = excluding {
            predicateFormat += " AND self != %@"
            predicateArgs.append(excluding)
        }
        
        let predicate = NSPredicate(format: predicateFormat, argumentArray: predicateArgs)
        let existing = try coreDataManager.fetch(PlanBlockInstance.self,
                                               predicate: predicate,
                                               context: context)
        return !existing.isEmpty
    }
}

// MARK: - 错误定义

enum PlanBlockInstanceError: LocalizedError {
    case invalidTimeRange
    case timeConflict
    case planInstanceOutOfRange
    
    var errorDescription: String? {
        switch self {
        case .invalidTimeRange:
            return "结束时间必须晚于开始时间"
        case .timeConflict:
            return "时间范围与现有区间冲突"
        case .planInstanceOutOfRange:
            return "区间内存在计划实例超出新的时间范围"
        }
    }
} 