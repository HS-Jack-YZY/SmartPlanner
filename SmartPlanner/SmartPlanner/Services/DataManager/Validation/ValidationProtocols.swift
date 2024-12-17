import Foundation
import CoreData

// MARK: - 基础验证协议
protocol Validatable {
    /// 执行验证
    /// - Throws: ValidationError 如果验证失败
    func validate() throws
    
    /// 异步验证（用于复杂验证）
    /// - Returns: 如果验证失败则抛出错误
    func validateAsync() async throws
}

// MARK: - 字段验证协议
protocol FieldValidatable {
    /// 验证必填字段
    /// - Parameter field: 字段名称
    /// - Parameter value: 字段值
    /// - Throws: ValidationError 如果验证失败
    func validateRequired<T>(field: String, value: T?) throws
    
    /// 验证字符串长度
    /// - Parameters:
    ///   - value: 字符串值
    ///   - field: 字段名称
    ///   - minLength: 最小长度
    ///   - maxLength: 最大长度
    /// - Throws: ValidationError 如果验证失败
    func validateStringLength(_ value: String, field: String, minLength: Int, maxLength: Int) throws
    
    /// 验证数值范围
    /// - Parameters:
    ///   - value: 数值
    ///   - field: 字段名称
    ///   - min: 最小值
    ///   - max: 最大值
    /// - Throws: ValidationError 如果验证失败
    func validateRange<T: Comparable>(_ value: T, field: String, min: T, max: T) throws
    
    /// 验证十六进制颜色格式
    /// - Parameters:
    ///   - color: 颜色字符串
    ///   - field: 字段名称
    ///   - allowsAlpha: 是否允许 alpha 通道
    /// - Throws: ValidationError 如果验证失败
    func validateHexColor(_ color: String, field: String, allowsAlpha: Bool) throws
}

// MARK: - 关系验证协议
protocol RelationValidatable {
    /// 验证必要关系
    /// - Parameter name: 关系名称
    /// - Parameter value: 关系对象
    /// - Throws: ValidationError 如果验证失败
    func validateRequiredRelation<T>(name: String, value: T) throws
    
    /// 验证关系集合
    /// - Parameters:
    ///   - values: 关系对象集合
    ///   - name: 关系名称
    ///   - maxCount: 最大数量
    /// - Throws: ValidationError 如果验证失败
    func validateRelationSet<T>(_ values: Set<T>, name: String, maxCount: Int?) throws
}

// MARK: - 时间验证协议
protocol TimeValidatable {
    /// 验证时间顺序
    /// - Parameters:
    ///   - startTime: 开始时间
    ///   - endTime: 结束时间
    /// - Throws: ValidationError 如果验证失败
    func validateTimeOrder(startTime: Date, endTime: Date) throws
    
    /// 验证计划时间是否在区间范围内
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
    ) throws
    
    /// 验证区间时间冲突
    /// - Parameters:
    ///   - startTime: 开始时间
    ///   - endTime: 结束时间
    ///   - existingBlocks: 现有区间实例集合
    /// - Throws: ValidationError 如果验证失败
    func validateBlockTimeConflict(
        startTime: Date,
        endTime: Date,
        existingBlocks: [PlanBlockInstance]
    ) throws
    
    /// 验证计划时间冲突
    /// - Parameters:
    ///   - startTime: 开始时间
    ///   - endTime: 结束时间
    ///   - existingInstances: 现有计划实例集合
    /// - Throws: ValidationError 如果验证失败
    func validatePlanTimeConflict(
        startTime: Date,
        endTime: Date,
        existingInstances: [PlanInstance]
    ) throws
}

// MARK: - 缓存验证协议
protocol ValidationCacheable {
    /// 获取缓存的验证结果
    /// - Parameter key: 缓存键
    /// - Returns: 上次验证时间
    func getValidationCache(for key: String) -> Date?
    
    /// 设置验证缓存
    /// - Parameters:
    ///   - key: 缓存键
    ///   - date: 验证时间
    func setValidationCache(for key: String, date: Date)
    
    /// 清除验证缓存
    /// - Parameter key: 缓存键
    func clearValidationCache(for key: String)
}

// MARK: - FieldValidatable Extension
extension FieldValidatable {
    func validateRequired<T>(field: String, value: T?) throws {
        guard let _ = value else {
            throw ValidationError.requiredFieldMissing(field: field)
        }
    }
    
    func validateStringLength(_ value: String, field: String, minLength: Int, maxLength: Int) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count < minLength || trimmed.count > maxLength {
            throw ValidationError.invalidLength(field: field, min: minLength, max: maxLength)
        }
    }
    
    func validateRange<T: Comparable>(_ value: T, field: String, min: T, max: T) throws {
        if value < min || value > max {
            throw ValidationError.invalidRange(field: field, min: min, max: max)
        }
    }
    
    /// 验证十六进制颜色格式（便利方法）
    /// - Parameter color: 颜色字符串
    /// - Throws: ValidationError 如果验证失败
    func validateHexColor(_ color: String) throws {
        try validateHexColor(color, field: "color", allowsAlpha: true)
    }
    
    /// 验证十六进制颜色格式（便利方法）
    /// - Parameters:
    ///   - color: 颜色字符串
    ///   - field: 字段名称
    /// - Throws: ValidationError 如果验证失败
    func validateHexColor(_ color: String, field: String) throws {
        try validateHexColor(color, field: field, allowsAlpha: true)
    }
    
    /// 验证十六进制颜色格式的具体实现
    func validateHexColor(_ color: String, field: String, allowsAlpha: Bool) throws {
        let hexPattern = allowsAlpha ? "^#[0-9A-Fa-f]{8}$" : "^#[0-9A-Fa-f]{6}$"
        let formatDescription = allowsAlpha ? "#RRGGBBAA" : "#RRGGBB"
        
        guard let regex = try? NSRegularExpression(pattern: hexPattern) else {
            throw ValidationError.systemError(description: "颜色验证正则表达式无效")
        }
        
        let range = NSRange(location: 0, length: color.utf16.count)
        if regex.firstMatch(in: color, range: range) == nil {
            throw ValidationError.invalidFormat(field: field, expectedFormat: formatDescription)
        }
    }
}

// MARK: - RelationValidatable Extension
extension RelationValidatable {
    func validateRequiredRelation<T>(name: String, value: T) throws {
        // 非可选类型不需要验证是否为空
    }
    
    func validateRelationSet<T>(_ values: Set<T>, name: String, maxCount: Int?) throws {
        if let max = maxCount, values.count > max {
            throw ValidationError.businessRuleViolation(rule: "\(name)数量不能超过\(max)个")
        }
    }
}

// MARK: - TimeValidatable Extension
extension TimeValidatable {
    func validateTimeOrder(startTime: Date, endTime: Date) throws {
        try ValidationRules.shared.validateTimeOrder(startTime: startTime, endTime: endTime)
    }
    
    func validatePlanTimeInBlockRange(
        planStartTime: Date,
        planEndTime: Date,
        blockStartTime: Date,
        blockEndTime: Date
    ) throws {
        try ValidationRules.shared.validatePlanTimeInBlockRange(
            planStartTime: planStartTime,
            planEndTime: planEndTime,
            blockStartTime: blockStartTime,
            blockEndTime: blockEndTime
        )
    }
    
    func validateBlockTimeConflict(
        startTime: Date,
        endTime: Date,
        existingBlocks: [PlanBlockInstance]
    ) throws {
        try ValidationRules.shared.validateBlockTimeConflict(
            startTime: startTime,
            endTime: endTime,
            existingBlocks: existingBlocks
        )
    }
    
    func validatePlanTimeConflict(
        startTime: Date,
        endTime: Date,
        existingInstances: [PlanInstance]
    ) throws {
        try ValidationRules.shared.validatePlanTimeConflict(
            startTime: startTime,
            endTime: endTime,
            existingInstances: existingInstances
        )
    }
} 
