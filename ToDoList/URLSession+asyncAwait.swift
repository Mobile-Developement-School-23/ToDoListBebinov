//
//  URLSession+asyncAwait.swift
//  ToDoList
//
//  Created by Fedor Bebinov on 06.07.2023.
//

import Foundation

extension URLSession {

    func data(with request: URLRequest) async throws -> (Data?, URLResponse?) {
        let sessionTask = SessionTask()
        return try await withTaskCancellationHandler {
            return try await withCheckedThrowingContinuation { continuation in
                sessionTask.dataTask = dataTask(with: request) { data, response, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(with: .success((data, response)))
                }
                sessionTask.dataTask?.resume()
            }
        } onCancel: {
            sessionTask.dataTask?.cancel()
        }
    }
}

class SessionTask {

    var dataTask: URLSessionDataTask?
}
