import Foundation
import CoreData

/// PlanCategory 的验证扩展
extension PlanCategory: Validatable, FieldValidatable, RelationValidatable {
    func validate() throws {
        // 基础字段验证
        try validateStringLength(name, field: "name", minLength: 1, maxLength: 100)
        try validateHexColor(color)
        try validateRange(level, field: "level", min: 0, max: 5)
        
        if let path = path {
            try validateStringLength(path, field: "path", minLength: 0, maxLength: 255)
        }
        
        // 时间验证
        if createdAt > Date() {
            throw ValidationError.invalidTimeRange(description: "创建时间不能是未来时间")
        }
        
        if updatedAt < createdAt {
            throw ValidationError.invalidTimeRange(description: "更新时间不能早于创建时间")
        }
        
        // 关系验证
        if let parent = self.parent {
            try validateCategoryCircularReference(parent)
            try ValidationRules.shared.validateCategoryDepth(parent)
        }
        
        try ValidationRules.shared.validateTemplateCount(self, templates: planTemplates)
    }
    
    func validateAsync() async throws {
        // 异步验证逻辑（如需要）
        try validate()
    }
    
    // MARK: - Private Methods
    
    private func validateCategoryCircularReference(_ category: PlanCategory, visited: Set<NSManagedObjectID> = []) throws {
        try ValidationRules.shared.validateCategoryCircularReference(category, visited: visited)
    }
} 