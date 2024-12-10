//
//  PlanTemplateService.swift
//  SmartPlanner
//
//  Created by HS_Jack_YZY on 2024/12/11.
//

import CoreData
import Foundation

/// PlanTemplate 服务协议
protocol PlanTemplateServiceProtocol {
    /// 创建计划模板
    /// - Parameters:
    ///   - name: 模板名称
    ///   - category: 所属类别（可选）
    ///   - color: 显示颜色（可选）
    ///   - isFixedTime: 是否为固定时间计划
    ///   - isReminderEnabled: 是否启用提醒
    ///   - reminderTime: 提醒时间（分钟）
    ///   - priority: 优先级（1-5）
    ///   - difficulty: 难度等级（1-5）
    ///   - tags: 标签（可选）
    /// - Returns: 创建的计划模板实体
    func createTemplate(name: String,
                       category: Category?,
                       color: String?,
                       isFixedTime: Bool,
                       isReminderEnabled: Bool,
                       reminderTime: Int32?,
                       priority: Int16?,
                       difficulty: Int16?,
                       tags: String?) throws -> PlanTemplate
    
    /// 获取指定类别的计划��板
    /// - Parameter category: 类别（nil表示获取未分类的模板）
    /// - Returns: 计划模板列表
    func fetchTemplates(in category: Category?) throws -> [PlanTemplate]
    
    /// 获取所有计划模板
    /// - Returns: 所有计划模板列表
    func fetchAllTemplates() throws -> [PlanTemplate]
    
    /// 获取指定模板的所有实例
    /// - Parameter template: 计划模板
    /// - Returns: 计划实例列表
    func fetchInstances(of template: PlanTemplate) throws -> [PlanInstance]
    
    /// 更新计划模板信息
    /// - Parameters:
    ///   - template: 要更新的模板
    ///   - name: 新名称（可选）
    ///   - category: 新类别（可选）
    ///   - color: 新颜色（可选）
    ///   - isFixedTime: 是否固定时间（可选）
    ///   - isReminderEnabled: 是否启用提醒（可选）
    ///   - reminderTime: 提醒时间（可选）
    ///   - priority: 优先级（可选）
    ///   - difficulty: 难度等级（可选）
    ///   - tags: 标签（可选）
    func updateTemplate(_ template: PlanTemplate,
                       name: String?,
                       category: Category?,
                       color: String?,
                       isFixedTime: Bool?,
                       isReminderEnabled: Bool?,
                       reminderTime: Int32?,
                       priority: Int16?,
                       difficulty: Int16?,
                       tags: String?) throws
    
    /// 删除计划模板（软删除）
    /// - Parameter template: 要删除的模板
    func deleteTemplate(_ template: PlanTemplate) throws
    
    /// 检查模板名称是否可用
    /// - Parameters:
    ///   - name: 要检查的名称
    ///   - category: 所属类别（可选）
    ///   - excluding: 排除的模板（用于更新时）
    /// - Returns: 名称是否可用
    func isNameAvailable(_ name: String,
                        category: Category?,
                        excluding: PlanTemplate?) throws -> Bool
    
    /// 创建计划实例
    /// - Parameters:
    ///   - template: 计划模板
    ///   - blockInstance: 所属区间实例
    ///   - startTime: 开始时间
    ///   - endTime: 结束时间
    /// - Returns: 创建的计划实例
    func createInstance(from template: PlanTemplate,
                       in blockInstance: PlanBlockInstance,
                       startTime: Date,
                       endTime: Date) throws -> PlanInstance
}

/// PlanTemplate 服务实现
final class PlanTemplateService: PlanTemplateServiceProtocol {
    /// CoreData 管理器
    private let coreDataManager: CoreDataManager
    
    /// 初始化方法
    /// - Parameter coreDataManager: CoreData 管理器实例
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - 创建操作
    
    func createTemplate(name: String,
                       category: Category?,
                       color: String?,
                       isFixedTime: Bool,
                       isReminderEnabled: Bool,
                       reminderTime: Int32?,
                       priority: Int16?,
                       difficulty: Int16?,
                       tags: String?) throws -> PlanTemplate {
        // 验证名称是否可用
        guard try isNameAvailable(name, category: category, excluding: nil) else {
            throw PlanTemplateError.nameAlreadyExists
        }
        
        // 验证优先级和难度值
        if let priority = priority {
            guard (1...5).contains(priority) else {
                throw PlanTemplateError.invalidPriority
            }
        }
        
        if let difficulty = difficulty {
            guard (1...5).contains(difficulty) else {
                throw PlanTemplateError.invalidDifficulty
            }
        }
        
        let context = coreDataManager.mainContext
        let template = coreDataManager.create(PlanTemplate.self, context: context)
        
        // 设置基本属性
        template.id = UUID()
        template.name = name
        template.category = category
        template.color = color
        template.isFixedTime = isFixedTime
        template.isReminderEnabled = isReminderEnabled
        template.reminderTime = reminderTime ?? 0
        template.priority = priority ?? 0
        template.difficulty = difficulty ?? 0
        template.tags = tags
        template.createdAt = Date()
        template.updatedAt = Date()
        
        try coreDataManager.saveContext(context)
        return template
    }
    
    func createInstance(from template: PlanTemplate,
                       in blockInstance: PlanBlockInstance,
                       startTime: Date,
                       endTime: Date) throws -> PlanInstance {
        // 验证时间
        guard endTime > startTime else {
            throw PlanTemplateError.invalidTimeRange
        }
        
        // 验证时间是否在区间范围内
        guard startTime >= blockInstance.startAt! && endTime <= blockInstance.endAt! else {
            throw PlanTemplateError.timeOutOfBlockRange
        }
        
        let context = coreDataManager.mainContext
        let instance = coreDataManager.create(PlanInstance.self, context: context)
        
        // 设置��本属性
        instance.id = UUID()
        instance.startTime = startTime
        instance.endTime = endTime
        instance.duration = Int32(endTime.timeIntervalSince(startTime) / 60)
        instance.isReminderEnabled = template.isReminderEnabled
        instance.reminderTime = template.reminderTime
        instance.priority = template.priority
        instance.difficulty = template.difficulty
        instance.createdAt = Date()
        instance.updatedAt = Date()
        instance.planTemplate = template
        instance.blockInstance = blockInstance
        
        try coreDataManager.saveContext(context)
        return instance
    }
    
    // MARK: - 查询操作
    
    func fetchTemplates(in category: Category?) throws -> [PlanTemplate] {
        let context = coreDataManager.mainContext
        let predicate = category == nil ?
            NSPredicate(format: "category == nil AND deletedAt == nil") :
            NSPredicate(format: "category == %@ AND deletedAt == nil", category!)
        return try coreDataManager.fetch(PlanTemplate.self,
                                       predicate: predicate,
                                       context: context)
    }
    
    func fetchAllTemplates() throws -> [PlanTemplate] {
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: "deletedAt == nil")
        return try coreDataManager.fetch(PlanTemplate.self,
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
    
    // MARK: - 更新操作
    
    func updateTemplate(_ template: PlanTemplate,
                       name: String?,
                       category: Category?,
                       color: String?,
                       isFixedTime: Bool?,
                       isReminderEnabled: Bool?,
                       reminderTime: Int32?,
                       priority: Int16?,
                       difficulty: Int16?,
                       tags: String?) throws {
        // 如果要更新名称，先验证是否可用
        if let name = name {
            guard try isNameAvailable(name, category: category ?? template.category,
                                    excluding: template) else {
                throw PlanTemplateError.nameAlreadyExists
            }
            template.name = name
        }
        
        // 验证优先级和难度值
        if let priority = priority {
            guard (1...5).contains(priority) else {
                throw PlanTemplateError.invalidPriority
            }
            template.priority = priority
        }
        
        if let difficulty = difficulty {
            guard (1...5).contains(difficulty) else {
                throw PlanTemplateError.invalidDifficulty
            }
            template.difficulty = difficulty
        }
        
        // 更新其他属性
        if let category = category {
            template.category = category
        }
        
        if let color = color {
            template.color = color
        }
        
        if let isFixedTime = isFixedTime {
            template.isFixedTime = isFixedTime
        }
        
        if let isReminderEnabled = isReminderEnabled {
            template.isReminderEnabled = isReminderEnabled
        }
        
        if let reminderTime = reminderTime {
            template.reminderTime = reminderTime
        }
        
        if let tags = tags {
            template.tags = tags
        }
        
        template.updatedAt = Date()
        
        try coreDataManager.saveContext(coreDataManager.mainContext)
    }
    
    // MARK: - 删除操作
    
    func deleteTemplate(_ template: PlanTemplate) throws {
        let context = coreDataManager.mainContext
        try coreDataManager.delete(template, context: context)
    }
    
    // MARK: - 验证方法
    
    func isNameAvailable(_ name: String,
                        category: Category?,
                        excluding: PlanTemplate?) throws -> Bool {
        let context = coreDataManager.mainContext
        var predicateFormat = "name == %@ AND deletedAt == nil"
        var predicateArgs: [Any] = [name]
        
        if let category = category {
            predicateFormat += " AND category == %@"
            predicateArgs.append(category)
        } else {
            predicateFormat += " AND category == nil"
        }
        
        if let excluding = excluding {
            predicateFormat += " AND self != %@"
            predicateArgs.append(excluding)
        }
        
        let predicate = NSPredicate(format: predicateFormat, argumentArray: predicateArgs)
        let existing = try coreDataManager.fetch(PlanTemplate.self,
                                               predicate: predicate,
                                               context: context)
        return existing.isEmpty
    }
}

// MARK: - 错误定义

enum PlanTemplateError: LocalizedError {
    case nameAlreadyExists
    case invalidTimeRange
    case timeOutOfBlockRange
    case invalidPriority
    case invalidDifficulty
    
    var errorDescription: String? {
        switch self {
        case .nameAlreadyExists:
            return "计划模板名称已存在"
        case .invalidTimeRange:
            return "结束时间必须晚于开始时间"
        case .timeOutOfBlockRange:
            return "计划时间必须在区间范围内"
        case .invalidPriority:
            return "优先级必须在1-5之间"
        case .invalidDifficulty:
            return "难度等级必须在1-5之间"
        }
    }
} 