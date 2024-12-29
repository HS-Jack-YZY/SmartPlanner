import Foundation
import CoreData

/// 验证规则实现
final class ValidationRules {
    // MARK: - Singleton
    static let shared = ValidationRules()
    private init() {}
    
    // MARK: - Public Properties
    /// 每个模板最大实例数量
    var maxInstancesPerTemplate: Int { Constants.maxInstancesPerTemplate }
    
    /// 每个类别最大模板数量
    var maxTemplatesPerCategory: Int { Constants.maxTemplatesPerCategory }
    
    /// 类别最大深度
    var maxCategoryDepth: Int { Constants.maxCategoryDepth }
    
    /// 批量操作最大数量
    var maxBatchSize: Int { Constants.maxBatchSize }
    
    // MARK: - Constants
    private enum Constants {
        static let maxCacheTime: TimeInterval = 300 // 5分钟缓存
        static let maxCategoryDepth: Int = 5
        static let maxTemplatesPerCategory: Int = 500
        static let maxInstancesPerTemplate: Int = 1000
        static let maxBatchSize: Int = 100
    }
    
    // MARK: - Cache
    private var validationCache: [String: Date] = [:]
    
    // MARK: - Validation Methods
    
    /// 验证时间顺序（确保结束时间晚于开始时间）
    /// - Parameters:
    ///   - startTime: 开始时间
    ///   - endTime: 结束时间
    /// - Throws: ValidationError 如果验证失败
    func validateTimeOrder(startTime: Date, endTime: Date) throws {
        if endTime <= startTime {
            throw ValidationError.invalidTimeRange(
                description: "结束时间必须晚于开始时间"
            )
        }
    }
    
    /// 验证计划实例的时间是否在区间实例的范围内
    /// - Parameters:
    ///   - planStartTime: 计划开始时间
    ///   - planEndTime: 计划结束时间
    ///   - blockStartTime: 区间开始时间
    ///   - blockEndTime: 区间结束时间
    /// - Throws: ValidationError 如果验证失败
    func validatePlanTimeInBlockRange(
        planStartTime: Date,
        planEndTime: Date,
        blockStartTime: Date,
        blockEndTime: Date
    ) throws {
        if planStartTime < blockStartTime || planEndTime > blockEndTime {
            throw ValidationError.invalidTimeRange(
                description: "计划时间必须在所属区间的时间范围内"
            )
        }
    }
    
    /// 验证区间实例之间是否存在时间冲突
    /// - Parameters:
    ///   - startTime: 要验证的开始时间
    ///   - endTime: 要验证的结束时间
    ///   - existingBlocks: 现有的区间实例集合
    /// - Throws: ValidationError 如果验证失败
    func validateBlockTimeConflict(
        startTime: Date,
        endTime: Date,
        existingBlocks: [PlanBlockInstance]
    ) throws {
        for block in existingBlocks {
            // 检查是否有重叠
            if max(startTime, block.startAt) < min(endTime, block.endAt) {
                throw ValidationError.timeConflict(
                    description: "区间时间与现有区间（\(block.blockTemplate.name)）冲突"
                )
            }
        }
    }
    
    /// 验证计划实例之间是否存在时间冲突
    /// - Parameters:
    ///   - startTime: 要验证的开始时间
    ///   - endTime: 要验证的结束时间
    ///   - existingInstances: 现有的计划实例集合
    /// - Throws: ValidationError 如果验证失败
    func validatePlanTimeConflict(
        startTime: Date,
        endTime: Date,
        existingInstances: [PlanInstance]
    ) throws {
        for instance in existingInstances {
            // 检查是否有重叠
            if max(startTime, instance.startTime) < min(endTime, instance.endTime) {
                throw ValidationError.timeConflict(
                    description: "计划时间与现有计划（\(instance.planTemplate.name)）��突"
                )
            }
        }
    }
    
    /// 验证类别深度
    /// - Parameters:
    ///   - category: 要验证的类别
    ///   - currentDepth: 当前深度
    /// - Throws: ValidationError 如果验证失败
    func validateCategoryDepth(_ category: PlanCategory, currentDepth: Int = 0) throws {
        if currentDepth >= maxCategoryDepth {
            throw ValidationError.maxDepthExceeded(description: "类别层级不能超过\(maxCategoryDepth)层")
        }
        
        // 递归验证子类别
        try category.children.forEach { child in
            try validateCategoryDepth(child, currentDepth: currentDepth + 1)
        }
    }
    
    /// 验证类别循环引用
    /// - Parameters:
    ///   - category: 要验证的类别
    ///   - visited: 已访问的类别ID集合
    /// - Throws: ValidationError 如果验证失败
    func validateCategoryCircularReference(_ category: PlanCategory, visited: Set<NSManagedObjectID> = []) throws {
        var visited = visited
        
        if visited.contains(category.objectID) {
            throw ValidationError.circularReference(description: "检测到类别循环引用")
        }
        
        visited.insert(category.objectID)
        
        if let parent = category.parent {
            try validateCategoryCircularReference(parent, visited: visited)
        }
    }
    
    /// 验证模板数量限制
    /// - Parameters:
    ///   - category: 类别
    ///   - templates: 模板集合
    /// - Throws: ValidationError 如果验证失败
    func validateTemplateCount(_ category: PlanCategory, templates: Set<PlanTemplate>) throws {
        if templates.count > maxTemplatesPerCategory {
            throw ValidationError.businessRuleViolation(
                rule: "单个类别下的模板数量不能超过\(maxTemplatesPerCategory)个"
            )
        }
    }
    
    /// 验证实例数量限制
    /// - Parameters:
    ///   - template: 模板
    ///   - instances: 实例集合
    /// - Throws: ValidationError 如果验证失败
    func validateInstanceCount(_ template: PlanTemplate, instances: Set<PlanInstance>) throws {
        if instances.count > maxInstancesPerTemplate {
            throw ValidationError.businessRuleViolation(
                rule: "单个模板的实例数量不能超过\(maxInstancesPerTemplate)个"
            )
        }
    }
    
    /// 验证批量操作数量
    /// - Parameter count: 操作数量
    /// - Throws: ValidationError 如果验证失败
    func validateBatchSize(_ count: Int) throws {
        if count > maxBatchSize {
            throw ValidationError.businessRuleViolation(
                rule: "批量操作数量不能超过\(maxBatchSize)条"
            )
        }
    }
}

// MARK: - ValidationCacheable Implementation
extension ValidationRules: ValidationCacheable {
    func getValidationCache(for key: String) -> Date? {
        validationCache[key]
    }
    
    func setValidationCache(for key: String, date: Date) {
        validationCache[key] = date
    }
    
    func clearValidationCache(for key: String) {
        validationCache.removeValue(forKey: key)
    }
} 
