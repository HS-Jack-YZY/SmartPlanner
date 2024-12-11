//
//  PlanInstance+CoreDataProperties.swift
//  SmartPlanner
//
//  Created by 袁哲奕 on 2024/12/11.
//
//

import Foundation
import CoreData


extension PlanInstance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlanInstance> {
        return NSFetchRequest<PlanInstance>(entityName: "PlanInstance")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var difficulty: Int16
    @NSManaged public var duration: Int32
    @NSManaged public var endTime: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isReminderEnabled: Bool
    @NSManaged public var priority: Int16
    @NSManaged public var reminderTime: Int32
    @NSManaged public var startTime: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var blockInstance: PlanBlockInstance?
    @NSManaged public var planTemplate: PlanTemplate?

}

extension PlanInstance : Identifiable {

}
