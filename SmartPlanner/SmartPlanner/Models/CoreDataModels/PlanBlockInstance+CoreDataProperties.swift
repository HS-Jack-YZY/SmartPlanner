//
//  PlanBlockInstance+CoreDataProperties.swift
//  SmartPlanner
//
//  Created by 袁哲奕 on 2024/12/17.
//
//

import Foundation
import CoreData


extension PlanBlockInstance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlanBlockInstance> {
        return NSFetchRequest<PlanBlockInstance>(entityName: "PlanBlockInstance")
    }

    @NSManaged public var createdAt: Date
    @NSManaged public var deletedAt: Date?
    @NSManaged public var endAt: Date
    @NSManaged public var id: UUID
    @NSManaged public var startAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var blockTemplate: PlanBlockTemplate
    @NSManaged public var planInstances: Set<PlanInstance>

}

// MARK: Generated accessors for planInstances
extension PlanBlockInstance {

    @objc(addPlanInstancesObject:)
    @NSManaged public func addToPlanInstances(_ value: PlanInstance)

    @objc(removePlanInstancesObject:)
    @NSManaged public func removeFromPlanInstances(_ value: PlanInstance)

    @objc(addPlanInstances:)
    @NSManaged public func addToPlanInstances(_ values: NSSet)

    @objc(removePlanInstances:)
    @NSManaged public func removeFromPlanInstances(_ values: NSSet)

}

extension PlanBlockInstance : Identifiable {

}
