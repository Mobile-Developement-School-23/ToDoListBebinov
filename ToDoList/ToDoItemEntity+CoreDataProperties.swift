//
//  ToDoItemEntity+CoreDataProperties.swift
//  
//
//  Created by Fedor Bebinov on 11.07.2023.
//
//

import Foundation
import CoreData


extension ToDoItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoItemEntity> {
        return NSFetchRequest<ToDoItemEntity>(entityName: "ToDoItemEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var importance: String?
    @NSManaged public var deadline: Date?
    @NSManaged public var isDone: Bool
    @NSManaged public var creationDate: Date?
    @NSManaged public var modifiedDate: Date?

}
