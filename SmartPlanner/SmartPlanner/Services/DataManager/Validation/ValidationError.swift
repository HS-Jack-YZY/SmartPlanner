import Foundation

/// 验证错误类型
enum ValidationError: LocalizedError {
    // MARK: - 基础字段验证错误
    case invalidField(field: String, description: String)
    case requiredFieldMissing(field: String)
    case invalidFormat(field: String, expectedFormat: String)
    case invalidLength(field: String, min: Int, max: Int)
    case invalidRange(field: String, min: Any, max: Any)
    case invalidValue(field: String, value: Any, reason: String)
    
    // MARK: - 关系验证错误
    case invalidRelation(description: String)
    case relationMissing(description: String)
    case circularReference(description: String)
    case maxDepthExceeded(description: String)
    
    // MARK: - 业务规则错误
    case businessRuleViolation(rule: String)
    case timeConflict(description: String)
    case invalidTimeRange(description: String)
    case invalidStatus(current: String, expected: [String])
    
    // MARK: - 系统错误
    case systemError(description: String)
    case concurrencyError(description: String)
    case persistenceError(description: String)
    
    // MARK: - LocalizedError Implementation
    var errorDescription: String? {
        switch self {
        // 基础字段验证错误
        case .invalidField(let field, let description):
            return "字段'\(field)'验证失败: \(description)"
        case .requiredFieldMissing(let field):
            return "必填字段'\(field)'不能为空"
        case .invalidFormat(let field, let format):
            return "字段'\(field)'格式错误，应为: \(format)"
        case .invalidLength(let field, let min, let max):
            return "字段'\(field)'长度应在\(min)到\(max)之间"
        case .invalidRange(let field, let min, let max):
            return "字段'\(field)'的值应在\(min)到\(max)之间"
        case .invalidValue(let field, let value, let reason):
            return "字段'\(field)'的值'\(value)'无效: \(reason)"
            
        // 关系验证错误
        case .invalidRelation(let description):
            return "关系验证失败: \(description)"
        case .relationMissing(let description):
            return "缺少必要的关联: \(description)"
        case .circularReference(let description):
            return "检测到循环引用: \(description)"
        case .maxDepthExceeded(let description):
            return "超出最大深度限制: \(description)"
            
        // 业务规则错误
        case .businessRuleViolation(let rule):
            return "违反业务规则: \(rule)"
        case .timeConflict(let description):
            return "时间冲突: \(description)"
        case .invalidTimeRange(let description):
            return "无效的时间范围: \(description)"
        case .invalidStatus(let current, let expected):
            return "状态'\(current)'无效，应为: \(expected.joined(separator: ", "))"
            
        // 系统错误
        case .systemError(let description):
            return "系统错误: \(description)"
        case .concurrencyError(let description):
            return "并发错误: \(description)"
        case .persistenceError(let description):
            return "持久化错误: \(description)"
        }
    }
} 