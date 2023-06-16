//
//  ToDoItem.swift
//  ToDoList
//
//  Created by Fedor Bebinov on 13.06.2023.
//

import Foundation

struct ToDoItem{
    enum Importance {
        case low
        case basic
        case important
    }
    
    var id: String = UUID().uuidString
    let text: String
    let dedline: Date?
    let creationDate: Date
    
    var isDone: Bool
    var modifiedDate: Date?
    var importance: Importance
}

extension ToDoItem {
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
               let modifiedDateFl = jsonDict["changed_at"] as? CGFloat{
                let creationDate = Date(timeIntervalSince1970: creationDateFl)
                let modifiedDate = Date(timeIntervalSince1970: modifiedDateFl)
                let deadline = Date(timeIntervalSince1970: deadlineFl)
                let todoItem = ToDoItem(id:id, text: text, dedline: deadline, creationDate: creationDate, isDone: isDone, modifiedDate: modifiedDate, importance: importance)
                return todoItem
            } else {
                fatalError("Invalid JSON structure or type mismatch")
                return nil
            }
    }
}
