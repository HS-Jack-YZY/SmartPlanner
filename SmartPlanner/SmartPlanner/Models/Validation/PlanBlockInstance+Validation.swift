import Foundation
import CoreData

/// PlanBlockInstance 的验证扩展
extension PlanBlockInstance: Validatable, FieldValidatable, RelationValidatable, TimeValidatable {
    func validate() throws {
        // 时间验证
        if createdAt > Date() {
            throw ValidationError.invalidTimeRange(description: "创建时间不能是未来时间")
        }
        
        if updatedAt < createdAt {
            throw ValidationError.invalidTimeRange(description: "更新时间不能早于创建时间")
        }
        
        // 验证区间时间顺序
        try ValidationRules.shared.validateTimeOrder(startTime: startAt, endTime: endAt)
        
        // 验证与其他区间的时间冲突
        if let context = self.managedObjectContext {
            let fetchRequest: NSFetchRequest<PlanBlockInstance> = PlanBlockInstance.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "self != %@ AND deletedAt == nil", self)
            
            if let existingBlocks = try? context.fetch(fetchRequest) {
                try ValidationRules.shared.validateBlockTimeConflict(
                    startTime: startAt,
                    endTime: endAt,
                    existingBlocks: existingBlocks
                )
            }
        }
        
        // 关系验证
        try validateRequiredRelation(name: "blockTemplate", value: blockTemplate)
        
        // 验证所有计划实例的时间是否在区间范围内
        try validatePlanInstancesTimeRange()
    }
    
    func validateAsync() async throws {
        // 异步验证逻辑（如需要）
        try validate()
    }
    
    // MARK: - Private Methods
    
    private func validatePlanInstancesTimeRange() throws {
        for instance in planInstances {
            try ValidationRules.shared.validatePlanTimeInBlockRange(
                planStartTime: instance.startTime,
                planEndTime: instance.endTime,
                blockStartTime: startAt,
                blockEndTime: endAt
            )
        }
    }
} 