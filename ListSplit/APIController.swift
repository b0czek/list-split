//
//  APIController.swift
//  ListSplit
//
//  Created by Dariusz Majnert on 09/01/2025.
//

import Foundation

// Define an APIError enum for handling errors
enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case unknown(Error)
}

typealias APIResponse<T> = Result<(data: T, statusCode: Int), APIError>
typealias APIMessageResponse = APIResponse<Message>

class APIController {
    // Base URL of the API
    private let baseURL: URL

    // Shared singleton instance
    static let shared = APIController(baseURL: "https://listsplit.rsh-cnc.eu/")

    // Private initializer to prevent creating multiple instances
    private init(baseURL: String) {
        guard let url = URL(string: baseURL) else {
            fatalError("Invalid base URL")
        }
        self.baseURL = url
    }

    
        
        
        // Generic method to perform API requests
        func performRequest<T: Decodable>(
            endpoint: String,
            method: String = "GET",
            body: Data? = nil,
            headers: [String: String] = [:],
            completion: @escaping (APIResponse<T>) -> Void
        ) {
            guard let url = URL(string: endpoint, relativeTo: baseURL) else {
                completion(.failure(.invalidURL))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = method
            request.httpBody = body
            request.allHTTPHeaderFields = headers
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(.unknown(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.requestFailed))
                    return
                }
                
                let statusCode = httpResponse.statusCode

                
                guard let data = data else {
                    completion(.failure(.requestFailed))
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .custom { decoder in
                        let container = try decoder.singleValueContainer()
                        let dateString = try container.decode(String.self)
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)  // Assume UTC if no timezone is provided

                        guard let date = formatter.date(from: dateString) else {
                            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
                        }

                        return date
                    }

                    let decodedData = try decoder.decode(T.self, from: data)
                    completion(.success((data: decodedData, statusCode: statusCode)))
                } catch {
                    completion(.failure(.decodingFailed))
                }
            }

            task.resume()
        }
        
    // Generic method to perform API requests
    func performMessageRequest(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String] = [:],
        completion: @escaping (APIMessageResponse) -> Void
    ) {
        performRequest(endpoint: endpoint, method: method, body: body, headers: headers, completion: completion)
    }
    
    func performBlindRequest(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String] = [:],
        completion: @escaping (Result<Int, APIError>) -> Void
    ) {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.allHTTPHeaderFields = headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(.unknown(error)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                completion(.success(httpResponse.statusCode))
            } else {
                completion(.failure(.requestFailed))
            }
        }

        task.resume()
    }
}

