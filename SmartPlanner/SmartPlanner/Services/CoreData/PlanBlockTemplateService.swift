//
//  PlanBlockTemplateService.swift
//  SmartPlanner
//
//  Created by HS_Jack_YZY on 2024/12/11.
//

import CoreData
import Foundation

/// PlanBlockTemplate 服务协议
protocol PlanBlockTemplateServiceProtocol {
    /// 创建计划区间模板
    /// - Parameters:
    ///   - name: 模板名称
    ///   - color: 显示颜色（可选）
    ///   - desc: 描述（可选）
    /// - Returns: 创建的区间模板实体
    func createTemplate(name: String, color: String?, desc: String?) throws -> PlanBlockTemplate
    
    /// 获取所有可见的区间模板
    /// - Returns: 区间模板列表
    func fetchVisibleTemplates() throws -> [PlanBlockTemplate]
    
    /// 获取指定区间模板的所有实例
    /// - Parameter template: 区间模板
    /// - Returns: 区间实例列表
    func fetchInstances(of template: PlanBlockTemplate) throws -> [PlanBlockInstance]
    
    /// 更新区间模板信息
    /// - Parameters:
    ///   - template: 要更新的模板
    ///   - name: 新名称（可选）
    ///   - color: 新颜色（可选）
    ///   - desc: 新描述（可选）
    ///   - isVisible: 是否可见（可选）
    func updateTemplate(_ template: PlanBlockTemplate,
                       name: String?,
                       color: String?,
                       desc: String?,
                       isVisible: Bool?) throws
    
    /// 删除区间模板（软删除）
    /// - Parameter template: 要删除的模板
    func deleteTemplate(_ template: PlanBlockTemplate) throws
    
    /// 检查模板名称是否可用
    /// - Parameters:
    ///   - name: 要检查的名称
    ///   - excluding: 排除的模板（用于更新时）
    /// - Returns: 名称是否可用
    func isNameAvailable(_ name: String, excluding: PlanBlockTemplate?) throws -> Bool
    
    /// 创建区间实例
    /// - Parameters:
    ///   - template: 区间模板
    ///   - startAt: 开始时间
    ///   - endAt: 结束时间
    /// - Returns: 创建的区间实例
    func createInstance(from template: PlanBlockTemplate,
                       startAt: Date,
                       endAt: Date) throws -> PlanBlockInstance
}

/// PlanBlockTemplate 服务实现
final class PlanBlockTemplateService: PlanBlockTemplateServiceProtocol {
    /// CoreData 管理器
    private let coreDataManager: CoreDataManager
    
    /// 初始化方法
    /// - Parameter coreDataManager: CoreData 管理器实例
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - 创建操作
    
    func createTemplate(name: String, color: String?, desc: String?) throws -> PlanBlockTemplate {
        // 验证名称是否可用
        guard try isNameAvailable(name, excluding: nil) else {
            throw PlanBlockTemplateError.nameAlreadyExists
        }
        
        let context = coreDataManager.mainContext
        let template = coreDataManager.create(PlanBlockTemplate.self, context: context)
        
        // 设置基本属性
        template.id = UUID()
        template.name = name
        template.color = color
        template.desc = desc
        template.isVisible = true
        template.createdAt = Date()
        template.updatedAt = Date()
        
        try coreDataManager.saveContext(context)
        return template
    }
    
    func createInstance(from template: PlanBlockTemplate,
                       startAt: Date,
                       endAt: Date) throws -> PlanBlockInstance {
        // 验证时间
        guard endAt > startAt else {
            throw PlanBlockTemplateError.invalidTimeRange
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
    
    func fetchVisibleTemplates() throws -> [PlanBlockTemplate] {
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: "isVisible == YES AND deletedAt == nil")
        return try coreDataManager.fetch(PlanBlockTemplate.self,
                                       predicate: predicate,
                                       context: context)
    }
    
    func fetchInstances(of template: PlanBlockTemplate) throws -> [PlanBlockInstance] {
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: "blockTemplate == %@ AND deletedAt == nil", template)
        return try coreDataManager.fetch(PlanBlockInstance.self,
                                       predicate: predicate,
                                       context: context)
    }
    
    // MARK: - 更新操作
    
    func updateTemplate(_ template: PlanBlockTemplate,
                       name: String?,
                       color: String?,
                       desc: String?,
                       isVisible: Bool?) throws {
        // 如果要更新名称，先验证是否可用
        if let name = name {
            guard try isNameAvailable(name, excluding: template) else {
                throw PlanBlockTemplateError.nameAlreadyExists
            }
            template.name = name
        }
        
        if let color = color {
            template.color = color
        }
        
        if let desc = desc {
            template.desc = desc
        }
        
        if let isVisible = isVisible {
            template.isVisible = isVisible
        }
        
        template.updatedAt = Date()
        
        try coreDataManager.saveContext(coreDataManager.mainContext)
    }
    
    // MARK: - 删除操作
    
    func deleteTemplate(_ template: PlanBlockTemplate) throws {
        let context = coreDataManager.mainContext
        try coreDataManager.delete(template, context: context)
    }
    
    // MARK: - 验证方法
    
    func isNameAvailable(_ name: String, excluding: PlanBlockTemplate?) throws -> Bool {
        let context = coreDataManager.mainContext
        var predicateFormat = "name == %@ AND deletedAt == nil"
        var predicateArgs: [Any] = [name]
        
        if let excluding = excluding {
            predicateFormat += " AND self != %@"
            predicateArgs.append(excluding)
        }
        
        let predicate = NSPredicate(format: predicateFormat, argumentArray: predicateArgs)
        let existing = try coreDataManager.fetch(PlanBlockTemplate.self,
                                               predicate: predicate,
                                               context: context)
        return existing.isEmpty
    }
}

// MARK: - 错误定义

enum PlanBlockTemplateError: LocalizedError {
    case nameAlreadyExists
    case invalidTimeRange
    
    var errorDescription: String? {
        switch self {
        case .nameAlreadyExists:
            return "区间模板名称已存在"
        case .invalidTimeRange:
            return "结束时间必须晚于开始时间"
        }
    }
} 