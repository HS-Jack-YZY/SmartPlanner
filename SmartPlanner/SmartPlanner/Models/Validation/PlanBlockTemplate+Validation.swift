import Foundation
import CoreData

/// PlanBlockTemplate 的验证扩展
extension PlanBlockTemplate: Validatable, FieldValidatable, RelationValidatable {
    func validate() throws {
        // 基础字段验证
        try validateStringLength(name, field: "name", minLength: 1, maxLength: 100)
        try validateHexColor(color)
        
        if let description = desc {
            try validateStringLength(description, field: "desc", minLength: 0, maxLength: 1000)
        }
        
        // 时间验证
        if createdAt > Date() {
            throw ValidationError.invalidTimeRange(description: "创建时间不能是未来时间")
        }
        
        if updatedAt < createdAt {
            throw ValidationError.invalidTimeRange(description: "更新时间不能早于创建时间")
        }
        
        // 关系验证
        try validateBlockInstanceCount(blockInstances)
    }
    
    func validateAsync() async throws {
        // 异步验证逻辑（如需要）
        try validate()
    }
    
    // MARK: - Private Methods
    
    private func validateBlockInstanceCount(_ instances: Set<PlanBlockInstance>) throws {
        try validateRelationSet(
            instances,
            name: "blockInstances",
            maxCount: ValidationRules.shared.maxInstancesPerTemplate
        )
    }
} 