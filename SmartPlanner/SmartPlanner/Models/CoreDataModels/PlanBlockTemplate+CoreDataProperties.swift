//
//  PlanBlockTemplate+CoreDataProperties.swift
//  SmartPlanner
//
//  Created by 袁哲奕 on 2024/12/11.
//
//

import Foundation
import CoreData


extension PlanBlockTemplate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlanBlockTemplate> {
        return NSFetchRequest<PlanBlockTemplate>(entityName: "PlanBlockTemplate")
    }

    @NSManaged public var color: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var desc: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isVisible: Bool
    @NSManaged public var name: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var blockInstances: NSSet?

}

// MARK: Generated accessors for blockInstances
extension PlanBlockTemplate {

    @objc(addBlockInstancesObject:)
    @NSManaged public func addToBlockInstances(_ value: PlanBlockInstance)

    @objc(removeBlockInstancesObject:)
    @NSManaged public func removeFromBlockInstances(_ value: PlanBlockInstance)

    @objc(addBlockInstances:)
    @NSManaged public func addToBlockInstances(_ values: NSSet)

    @objc(removeBlockInstances:)
    @NSManaged public func removeFromBlockInstances(_ values: NSSet)

}

extension PlanBlockTemplate : Identifiable {

}
