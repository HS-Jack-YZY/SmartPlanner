//
//  PlanInstanceService.swift
//  SmartPlanner
//
//  Created by HS_Jack_YZY on 2024/12/11.
//

import CoreData
import Foundation

/// PlanInstance 服务协议
protocol PlanInstanceServiceProtocol {
    /// 创建计划实例
    /// - Parameters:
    ///   - template: 计划模板
    ///   - blockInstance: 所属区间实例
    ///   - startTime: 开始时间
    ///   - endTime: 结束时间
    ///   - isReminderEnabled: 是否启用提醒（可选，默认使用模板设置）
    ///   - reminderTime: 提醒时间（可选，默认使用模板设置）
    ///   - priority: 优先级（可选，默认使用模板设置）
    ///   - difficulty: 难度等级（可选，默认使用模板设置）
    /// - Returns: 创建的计划实例
    func createInstance(from template: PlanTemplate,
                       in blockInstance: PlanBlockInstance,
                       startTime: Date,
                       endTime: Date,
                       isReminderEnabled: Bool?,
                       reminderTime: Int32?,
                       priority: Int16?,
                       difficulty: Int16?) throws -> PlanInstance
    
    /// 获取指定时间范围内的计划实例
    /// - Parameters:
    ///   - start: 开始���间
    ///   - end: 结束时间
    /// - Returns: 计划实例列表
    func fetchInstances(between start: Date, and end: Date) throws -> [PlanInstance]
    
    /// 获取指定模板的所有计划实例
    /// - Parameter template: 计划模板
    /// - Returns: 计划实例列表
    func fetchInstances(of template: PlanTemplate) throws -> [PlanInstance]
    
    /// 获取指定区间实例中的所有计划实例
    /// - Parameter blockInstance: 区间实例
    /// - Returns: 计划实例列表
    func fetchInstances(in blockInstance: PlanBlockInstance) throws -> [PlanInstance]
    
    /// 更新计划实例
    /// - Parameters:
    ///   - instance: 要更新的实例
    ///   - startTime: 新的开始时间（可选）
    ///   - endTime: 新的结束时间（可选）
    ///   - isReminderEnabled: 是否启用提醒（可选）
    ///   - reminderTime: 提醒时间（可选）
    ///   - priority: 优先级（可选）
    ///   - difficulty: 难度等级（可选）
    func updateInstance(_ instance: PlanInstance,
                       startTime: Date?,
                       endTime: Date?,
                       isReminderEnabled: Bool?,
                       reminderTime: Int32?,
                       priority: Int16?,
                       difficulty: Int16?) throws
    
    /// 移动��划实例到新的区间
    /// - Parameters:
    ///   - instance: 要移动的实例
    ///   - newBlockInstance: 新的区间实例
    func moveInstance(_ instance: PlanInstance,
                     to newBlockInstance: PlanBlockInstance) throws
    
    /// 删除计划实例（软删除）
    /// - Parameter instance: 要删除的实例
    func deleteInstance(_ instance: PlanInstance) throws
    
    /// 检查时间范围是否有冲突
    /// - Parameters:
    ///   - startTime: 开始时间
    ///   - endTime: 结束时间
    ///   - template: 计划模板
    ///   - blockInstance: 区间实例
    ///   - excluding: 排除的实例（用于更新时）
    /// - Returns: 是否存在冲突
    func hasTimeConflict(startTime: Date,
                        endTime: Date,
                        template: PlanTemplate,
                        blockInstance: PlanBlockInstance,
                        excluding: PlanInstance?) throws -> Bool
}

/// PlanInstance 服务实现
final class PlanInstanceService: PlanInstanceServiceProtocol {
    /// CoreData 管理器
    private let coreDataManager: CoreDataManager
    
    /// 初始化方法
    /// - Parameter coreDataManager: CoreData 管理器实例
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - 创建操作
    
    func createInstance(from template: PlanTemplate,
                       in blockInstance: PlanBlockInstance,
                       startTime: Date,
                       endTime: Date,
                       isReminderEnabled: Bool?,
                       reminderTime: Int32?,
                       priority: Int16?,
                       difficulty: Int16?) throws -> PlanInstance {
        // 验证时间
        guard endTime > startTime else {
            throw PlanInstanceError.invalidTimeRange
        }
        
        // 验证时间是否在区间范围内
        guard startTime >= blockInstance.startAt! && endTime <= blockInstance.endAt! else {
            throw PlanInstanceError.timeOutOfBlockRange
        }
        
        // 检查时间冲突
        guard try !hasTimeConflict(startTime: startTime,
                                 endTime: endTime,
                                 template: template,
                                 blockInstance: blockInstance,
                                 excluding: nil) else {
            throw PlanInstanceError.timeConflict
        }
        
        // 验证优先级和难度值
        if let priority = priority {
            guard (1...5).contains(priority) else {
                throw PlanInstanceError.invalidPriority
            }
        }
        
        if let difficulty = difficulty {
            guard (1...5).contains(difficulty) else {
                throw PlanInstanceError.invalidDifficulty
            }
        }
        
        let context = coreDataManager.mainContext
        let instance = coreDataManager.create(PlanInstance.self, context: context)
        
        // 设置基本属性
        instance.id = UUID()
        instance.startTime = startTime
        instance.endTime = endTime
        instance.duration = Int32(endTime.timeIntervalSince(startTime) / 60)
        instance.isReminderEnabled = isReminderEnabled ?? template.isReminderEnabled
        instance.reminderTime = reminderTime ?? template.reminderTime
        instance.priority = priority ?? template.priority
        instance.difficulty = difficulty ?? template.difficulty
        instance.createdAt = Date()
        instance.updatedAt = Date()
        instance.planTemplate = template
        instance.blockInstance = blockInstance
        
        try coreDataManager.saveContext(context)
        return instance
    }
    
    // MARK: - 查询操作
    
    func fetchInstances(between start: Date, and end: Date) throws -> [PlanInstance] {
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: """
            (startTime <= %@ AND endTime >= %@) OR
            (startTime >= %@ AND startTime <= %@) OR
            (endTime >= %@ AND endTime <= %@) AND
            deletedAt == nil
            """,
            end as NSDate, start as NSDate,
            start as NSDate, end as NSDate,
            start as NSDate, end as NSDate)
        
        return try coreDataManager.fetch(PlanInstance.self,
                                       predicate: predicate,
                                       context: context)
    }
    
    func fetchInstances(of template: PlanTemplate) throws -> [PlanInstance] {
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: "planTemplate == %@ AND deletedAt == nil",
                                  template)
        return try coreDataManager.fetch(PlanInstance.self,
                                       predicate: predicate,
                                       context: context)
    }
    
    func fetchInstances(in blockInstance: PlanBlockInstance) throws -> [PlanInstance] {
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: "blockInstance == %@ AND deletedAt == nil",
                                  blockInstance)
        return try coreDataManager.fetch(PlanInstance.self,
                                       predicate: predicate,
                                       context: context)
    }
    
    // MARK: - 更新操作
    
    func updateInstance(_ instance: PlanInstance,
                       startTime: Date?,
                       endTime: Date?,
                       isReminderEnabled: Bool?,
                       reminderTime: Int32?,
                       priority: Int16?,
                       difficulty: Int16?) throws {
        let newStartTime = startTime ?? instance.startTime!
        let newEndTime = endTime ?? instance.endTime!
        
        // 验证时间
        guard newEndTime > newStartTime else {
            throw PlanInstanceError.invalidTimeRange
        }
        
        // 验证时间是否在区间范围内
        guard let blockInstance = instance.blockInstance,
              newStartTime >= blockInstance.startAt! && newEndTime <= blockInstance.endAt! else {
            throw PlanInstanceError.timeOutOfBlockRange
        }
        
        // 检查时间冲突
        guard try !hasTimeConflict(startTime: newStartTime,
                                 endTime: newEndTime,
                                 template: instance.planTemplate!,
                                 blockInstance: blockInstance,
                                 excluding: instance) else {
            throw PlanInstanceError.timeConflict
        }
        
        // 验证优先级和难度值
        if let priority = priority {
            guard (1...5).contains(priority) else {
                throw PlanInstanceError.invalidPriority
            }
            instance.priority = priority
        }
        
        if let difficulty = difficulty {
            guard (1...5).contains(difficulty) else {
                throw PlanInstanceError.invalidDifficulty
            }
            instance.difficulty = difficulty
        }
        
        // 更新时间相关属性
        if startTime != nil || endTime != nil {
            instance.startTime = newStartTime
            instance.endTime = newEndTime
            instance.duration = Int32(newEndTime.timeIntervalSince(newStartTime) / 60)
        }
        
        // 更新其他属性
        if let isReminderEnabled = isReminderEnabled {
            instance.isReminderEnabled = isReminderEnabled
        }
        
        if let reminderTime = reminderTime {
            instance.reminderTime = reminderTime
        }
        
        instance.updatedAt = Date()
        
        try coreDataManager.saveContext(coreDataManager.mainContext)
    }
    
    func moveInstance(_ instance: PlanInstance,
                     to newBlockInstance: PlanBlockInstance) throws {
        // 验证���间是否在新区间范围内
        guard instance.startTime! >= newBlockInstance.startAt! &&
                instance.endTime! <= newBlockInstance.endAt! else {
            throw PlanInstanceError.timeOutOfBlockRange
        }
        
        // 检查时间冲突
        guard try !hasTimeConflict(startTime: instance.startTime!,
                                 endTime: instance.endTime!,
                                 template: instance.planTemplate!,
                                 blockInstance: newBlockInstance,
                                 excluding: instance) else {
            throw PlanInstanceError.timeConflict
        }
        
        instance.blockInstance = newBlockInstance
        instance.updatedAt = Date()
        
        try coreDataManager.saveContext(coreDataManager.mainContext)
    }
    
    // MARK: - 删除操作
    
    func deleteInstance(_ instance: PlanInstance) throws {
        let context = coreDataManager.mainContext
        try coreDataManager.delete(instance, context: context)
    }
    
    // MARK: - 验证方法
    
    func hasTimeConflict(startTime: Date,
                        endTime: Date,
                        template: PlanTemplate,
                        blockInstance: PlanBlockInstance,
                        excluding: PlanInstance?) throws -> Bool {
        // 如果不是固定时间的计划，则不检查冲突
        guard template.isFixedTime else {
            return false
        }
        
        let context = coreDataManager.mainContext
        var predicateFormat = """
            planTemplate.isFixedTime == YES AND
            blockInstance == %@ AND
            ((startTime <= %@ AND endTime >= %@) OR
             (startTime >= %@ AND startTime <= %@) OR
             (endTime >= %@ AND endTime <= %@)) AND
            deletedAt == nil
            """
        var predicateArgs: [Any] = [
            blockInstance,
            endTime as NSDate, startTime as NSDate,
            startTime as NSDate, endTime as NSDate,
            startTime as NSDate, endTime as NSDate
        ]
        
        if let excluding = excluding {
            predicateFormat += " AND self != %@"
            predicateArgs.append(excluding)
        }
        
        let predicate = NSPredicate(format: predicateFormat, argumentArray: predicateArgs)
        let existing = try coreDataManager.fetch(PlanInstance.self,
                                               predicate: predicate,
                                               context: context)
        return !existing.isEmpty
    }
}

// MARK: - 错误定义

enum PlanInstanceError: LocalizedError {
    case invalidTimeRange
    case timeOutOfBlockRange
    case timeConflict
    case invalidPriority
    case invalidDifficulty
    
    var errorDescription: String? {
        switch self {
        case .invalidTimeRange:
            return "结束时间必须晚于开始时间"
        case .timeOutOfBlockRange:
            return "计划时间必须在区间范围内"
        case .timeConflict:
            return "时间范围与现有计划冲突"
        case .invalidPriority:
            return "优先级必须在1-5之间"
        case .invalidDifficulty:
            return "难度等级必须在1-5之���"
        }
    }
} 