//
//  ToDoItem.swift
//  ToDoList
//
//  Created by Fedor Bebinov on 13.06.2023.
//

import Foundation

struct ToDoItem: Codable {
    enum Importance: String, Codable {
        case low
        case basic
        case important
    }
    
    var id: String = UUID().uuidString
    let text: String
    let deadline: Date?
    let creationDate: Date
    
    var isDone: Bool
    var modifiedDate: Date?
    var importance: Importance
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
            let deadlineFl = CGFloat(deadline.timeIntervalSince1970)
            items["deadline"] = deadlineFl
        }
        items["done"] = isDone
        let creationFl = CGFloat(creationDate.timeIntervalSince1970)
        items["created_at"] = creationFl
        if let modifiedDate{
            let modifiedFl = CGFloat(modifiedDate.timeIntervalSince1970)
            items["changed_at"] = modifiedFl
        }
        return items
    }

    static func parse (json: Any) -> ToDoItem? {
    
            guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
                return nil
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                return nil
            }
            
            if let jsonDict = jsonObject as? [String: Any],
               let id = jsonDict["id"] as? String,
               let text = jsonDict["text"] as? String,
               let importance = jsonDict["importance"] as? Importance,
               let deadlineFl = jsonDict["deadline"] as? CGFloat,
               let isDone = jsonDict["done"] as? Bool,
               let creationDateFl = jsonDict["created_at"] as? CGFloat,
               let modifiedDateFl = jsonDict["changed_at"] as? CGFloat {
                let creationDate = Date(timeIntervalSince1970: creationDateFl)
                let modifiedDate = Date(timeIntervalSince1970: modifiedDateFl)
                let deadline = Date(timeIntervalSince1970: deadlineFl)
                let todoItem = ToDoItem(id:id, text: text, deadline: deadline, creationDate: creationDate, isDone: isDone, modifiedDate: modifiedDate, importance: importance)
                return todoItem
            } else {
                return nil
            }
    }
}
