//
//  ToDoItem.swift
//  ToDoList
//
//  Created by Fedor Bebinov on 13.06.2023.
//

import Foundation

enum Importance: String, Codable {
    case low
    case basic
    case important
}
struct ToDoItem: Codable {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let creationDate: Date
    let modifiedDate: Date?
    
    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadline: Date? = nil,
        isDone: Bool = false,
        creationDate: Date = Date(),
        modifiedDate: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.creationDate = creationDate
        self.modifiedDate = modifiedDate
    }
}
 extension ToDoItem {
    var json: Any {
        var items: [String:Any] = [:]
        items["id"] = id
        items["text"] = text
        if importance != Importance.basic{
            items["importance"] = importance.rawValue
        }
        if let deadline{
            let deadlineFl = Int(deadline.timeIntervalSince1970)
            items["deadline"] = deadlineFl
        }
        items["done"] = isDone
        let creationFl = Int(creationDate.timeIntervalSince1970)
        items["created_at"] = creationFl
        if let modifiedDate{
            let modifiedFl = Int(modifiedDate.timeIntervalSince1970)
            items["changed_at"] = modifiedFl
        }
        return items
    }
     
     static func parse (json: Any) -> ToDoItem? {
         guard let js = json as? [String: Any] else {
             return nil
         }
         
         guard
            let id = js["id"] as? String,
            let text = js["text"] as? String,
            let createdAt = (js["created_at"] as? Int).flatMap ({ Date(timeIntervalSince1970: TimeInterval($0)) })
         else {
             return nil
         }
         
         let importance = (js["importance"] as? String).flatMap(Importance.init(rawValue:)) ?? .basic
         let deadline = (js["deadline"] as? Int).flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
         let isDone = (js["done"] as? Bool) ?? false
         let changedAt = (js["changed_at"] as? Int).flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
         
         return ToDoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, creationDate: createdAt, modifiedDate: changedAt)
     }
 }
