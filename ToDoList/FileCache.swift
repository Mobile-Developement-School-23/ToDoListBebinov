//
//  FileCache.swift
//  ToDoList
//
//  Created by Fedor Bebinov on 13.06.2023.
//

import Foundation
import CoreData

enum FileCacheErrors: Error {
    case cannotFindSystemDirectory
    case unparsableData
}

class FileCache {
    private(set) var items: [String: ToDoItem] = [:]
    
    private let container = NSPersistentContainer(name: "ToDoList")
    
    init() {
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
    
    @discardableResult
    func add(_ item: ToDoItem) -> ToDoItem? {
        let oldItem = items[item.id]
        items[item.id] = item
        return oldItem
    }
    
    @discardableResult
    func remove(_ id: String) -> ToDoItem? {
        let item = items[id]
        items[id] = nil
        return item
    }
    
    func save(to file: String) throws {
        let fm = FileManager.default
        guard let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.cannotFindSystemDirectory
        }
        
        let path = dir.appendingPathComponent("\(file).json")
        let serializedItems = items.map { _, item in item.json }
        let data = try JSONSerialization.data(withJSONObject: serializedItems, options: [])
        try data.write(to: path)
    }
    
    func saveToCoreData() {
        for (_, item) in items {
            let toDoItemEntity = NSEntityDescription.entity(forEntityName: "ToDoItemEntity", in: container.viewContext)!
            let toDoItemManagedObject = NSManagedObject(entity: toDoItemEntity, insertInto: container.viewContext)
            toDoItemManagedObject.setValue(item.id, forKeyPath: "id")
            toDoItemManagedObject.setValue(item.text, forKeyPath: "text")
            toDoItemManagedObject.setValue(item.deadline, forKeyPath: "deadline")
            toDoItemManagedObject.setValue(item.importance.rawValue, forKeyPath: "importance")
            toDoItemManagedObject.setValue(item.isDone, forKeyPath: "isDone")
            toDoItemManagedObject.setValue(item.creationDate, forKeyPath: "creationDate")
            toDoItemManagedObject.setValue(item.modifiedDate, forKeyPath: "modifiedDate")
        }
        do {
            try container.viewContext.save()
        } catch {
            print(error)
        }
    }
    
    func load(from file: String) throws {
        let fm = FileManager.default
        guard let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.cannotFindSystemDirectory
        }
        let path = dir.appendingPathComponent("\(file).json")
        let data = try Data(contentsOf: path)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let js = json as? [Any] else {
            throw FileCacheErrors.unparsableData
        }
        let deserializedItems = js.compactMap { ToDoItem.parse(json: $0) }
        self.items = deserializedItems.reduce(into: [:]) { res, item in
            res[item.id] = item
        }
    }
    
    func loadFromCoreData() {
        let request = ToDoItemEntity.fetchRequest()
        do {
            let elements: [ToDoItemEntity] = try container.viewContext.fetch(request)
            for element in elements {
                let toDoItem = ToDoItem(id: element.id!, text: element.text!, importance: Importance(rawValue: element.importance!)!, deadline: element.deadline, isDone: element.isDone, creationDate: element.creationDate!, modifiedDate: element.modifiedDate)
                items[toDoItem.id] = toDoItem
            }
        } catch {
            print(error)
        }
    }
}
