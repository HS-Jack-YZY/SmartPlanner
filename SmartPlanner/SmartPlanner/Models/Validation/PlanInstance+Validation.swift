import Foundation
import CoreData

/// PlanInstance 的验证扩展
extension PlanInstance: Validatable, FieldValidatable, RelationValidatable, TimeValidatable {
    func validate() throws {
        // 基础字段验证
        try validateRange(priority, field: "priority", min: 0, max: 5)
        try validateRange(difficulty, field: "difficulty", min: 0, max: 5)
        try validateRange(reminderTime, field: "reminderTime", min: 0, max: 1440)
        try validateRange(duration, field: "duration", min: 0, max: Int32.max)
        
        // 时间验证
        if createdAt > Date() {
            throw ValidationError.invalidTimeRange(description: "创建时间不能是未来时间")
        }
        
        if updatedAt < createdAt {
            throw ValidationError.invalidTimeRange(description: "更新时间不能早于创建时间")
        }
        
        // 验证计划时间顺序
        try ValidationRules.shared.validateTimeOrder(startTime: startTime, endTime: endTime)
        
        // 验证计划时间是否在区间范围内
        try ValidationRules.shared.validatePlanTimeInBlockRange(
            planStartTime: startTime,
            planEndTime: endTime,
            blockStartTime: blockInstance.startAt,
            blockEndTime: blockInstance.endAt
        )
        
        // 验证与其他计划的时间冲突
        if let context = self.managedObjectContext {
            let fetchRequest: NSFetchRequest<PlanInstance> = PlanInstance.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "self != %@ AND blockInstance == %@ AND deletedAt == nil",
                self, blockInstance
            )
            
            if let existingInstances = try? context.fetch(fetchRequest) {
                try ValidationRules.shared.validatePlanTimeConflict(
                    startTime: startTime,
                    endTime: endTime,
                    existingInstances: existingInstances
                )
            }
        }
        
        // 关系验证
        try validateRequiredRelation(name: "planTemplate", value: planTemplate)
        try validateRequiredRelation(name: "blockInstance", value: blockInstance)
    }
    
    func validateAsync() async throws {
        // 异步验证逻辑（如需要）
        try validate()
    }
} 