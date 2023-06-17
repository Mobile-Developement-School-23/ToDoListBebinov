//
//  FileCache.swift
//  ToDoList
//
//  Created by Fedor Bebinov on 13.06.2023.
//

import Foundation

class FileCache{
    private (set) var items = [ToDoItem]()
    private let fileName = "json"
    
    func addTask(newItem: ToDoItem) {
        for (index, item) in items.enumerated() {
            if item.id == newItem.id {
                items[index] = newItem
                return
            }
        }
        
        items.append(newItem)
        return
    }
    
    func deleteTask(id: String){
        for i in 0..<items.count{
            if items[i].id == id {
                items.remove(at: i)
                return
            }
        }
        print("task not found") // TODO: throw error
    }
    
    private func saveItems() {
        do {
            let data = try JSONEncoder().encode(items)
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save names: \(error)")
        }
    }
    
    private func loadItems() {
        let fileManager = FileManager.default
        do {
            let fileURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(fileName)
            
            if fileManager.fileExists(atPath: fileURL.path) {
                print("файл по имени json сушествует")
                let data = try Data(contentsOf: fileURL)
                items = try JSONDecoder().decode([ToDoItem].self, from: data)
                
                print("loadNames: \(items)")
            } else {
                print("зашли при первом запуске")
                items = []
                saveItems() // Create a new JSON file with an empty array
            }
        } catch {
            print("Failed to load names: \(error)")
        }
    }
}



