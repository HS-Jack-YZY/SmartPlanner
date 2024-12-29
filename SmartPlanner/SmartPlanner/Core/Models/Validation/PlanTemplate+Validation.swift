import Foundation
import CoreData

/// PlanTemplate 的验证扩展
extension PlanTemplate: Validatable, FieldValidatable, RelationValidatable {
    func validate() throws {
        // 基础字段验证
        try validateStringLength(name, field: "name", minLength: 1, maxLength: 100)
        try validateHexColor(color)
        try validateRange(priority, field: "priority", min: 0, max: 5)
        try validateRange(difficulty, field: "difficulty", min: 0, max: 5)
        try validateRange(reminderTime, field: "reminderTime", min: 0, max: 1440)
        
        if let tags = tags {
            try validateStringLength(tags, field: "tags", minLength: 0, maxLength: 1000)
            // TODO: 可以添加 JSON 格式验证
        }
        
        // 时间验证
        if createdAt > Date() {
            throw ValidationError.invalidTimeRange(description: "创建时间不能是未来时间")
        }
        
        if updatedAt < createdAt {
            throw ValidationError.invalidTimeRange(description: "更新时间不能早于创建时间")
        }
        
        // 关系验证
        try ValidationRules.shared.validateInstanceCount(self, instances: planInstances)
    }
    
    func validateAsync() async throws {
        // 异步验证逻辑（如需要）
        try validate()
    }
} 
