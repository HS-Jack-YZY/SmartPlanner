//
//  PlanCategory+CoreDataProperties.swift
//  SmartPlanner
//
//  Created by 袁哲奕 on 2024/12/11.
//
//

import Foundation
import CoreData


extension PlanCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlanCategory> {
        return NSFetchRequest<PlanCategory>(entityName: "PlanCategory")
    }

    @NSManaged public var color: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var displayOrder: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var isVisible: Bool
    @NSManaged public var level: Int16
    @NSManaged public var name: String?
    @NSManaged public var path: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var children: NSSet?
    @NSManaged public var parent: PlanCategory?
    @NSManaged public var planTemplates: NSSet?

}

// MARK: Generated accessors for children
extension PlanCategory {

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: PlanCategory)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: PlanCategory)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

}

// MARK: Generated accessors for planTemplates
extension PlanCategory {

    @objc(addPlanTemplatesObject:)
    @NSManaged public func addToPlanTemplates(_ value: PlanTemplate)

    @objc(removePlanTemplatesObject:)
    @NSManaged public func removeFromPlanTemplates(_ value: PlanTemplate)

    @objc(addPlanTemplates:)
    @NSManaged public func addToPlanTemplates(_ values: NSSet)

    @objc(removePlanTemplates:)
    @NSManaged public func removeFromPlanTemplates(_ values: NSSet)

}

extension PlanCategory : Identifiable {

}
