//
//  FileCache.swift
//  ToDoList
//
//  Created by Fedor Bebinov on 13.06.2023.
//

import Foundation

enum FileCacheErrors: Error {
    case cannotFindSystemDirectory
    case unparsableData
}

class FileCache{
    private(set) var items: [String: ToDoItem] = [:]
    
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
}



