//
//  PlanTemplate+CoreDataProperties.swift
//  SmartPlanner
//
//  Created by 袁哲奕 on 2024/12/11.
//
//

import Foundation
import CoreData


extension PlanTemplate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlanTemplate> {
        return NSFetchRequest<PlanTemplate>(entityName: "PlanTemplate")
    }

    @NSManaged public var color: String
    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var difficulty: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var isFixedTime: Bool
    @NSManaged public var isReminderEnabled: Bool
    @NSManaged public var name: String?
    @NSManaged public var priority: Int16
    @NSManaged public var reminderTime: Int32
    @NSManaged public var tags: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var planCategory: PlanCategory?
    @NSManaged public var planInstances: NSSet?

}

// MARK: Generated accessors for planInstances
extension PlanTemplate {

    @objc(addPlanInstancesObject:)
    @NSManaged public func addToPlanInstances(_ value: PlanInstance)

    @objc(removePlanInstancesObject:)
    @NSManaged public func removeFromPlanInstances(_ value: PlanInstance)

    @objc(addPlanInstances:)
    @NSManaged public func addToPlanInstances(_ values: NSSet)

    @objc(removePlanInstances:)
    @NSManaged public func removeFromPlanInstances(_ values: NSSet)

}

extension PlanTemplate : Identifiable {

}
