//
//  NetworkingService.swift
//  ToDoList
//
//  Created by Fedor Bebinov on 06.07.2023.
//

import Foundation

protocol NetworkingService {
    
    func createTodoItem() async
    
    func todoItemsList() async throws -> TodoItemsList?
    
}

class DefaultNetworkingService: NetworkingService {
    
    private let baseURLPath: String = "https://beta.mrdekk.ru/todobackend"
    
    func createTodoItem() async {
        
    }
    
    func todoItemsList() async throws -> TodoItemsList? {
        let url = URL(string: baseURLPath + "/list")
        var urlRequest = URLRequest(url: url!)
        urlRequest.addValue("Bearer flossification", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(with: urlRequest)
        let decoder = JSONDecoder()
        if let data {
            let todoItemsList = try decoder.decode(TodoItemsList.self, from: data)
            return todoItemsList
        }
        return nil
    }
    
}

class TodoItemsList: Codable{
    let status: String
    let list: [ToDoItem]
    let revision: Int32
}
