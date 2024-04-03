//
//  RemoteLoader.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 12/03/2024.
//

import Foundation

enum RemoteLoaderError: Error {
    case url
    case api(error: APIError)
    case misc(error: Error)
}

final class RemoteLoader {
    
    static let baseURL = "https://neru-febe6726-vapp-dev.euw1.runtime.vonage.cloud"
        
    static func post<T: Codable, U: Codable>(path: String,
                                             authToken: String? = nil,
                                             body: T?) async throws -> U {
        guard let url = URL(string: baseURL + path) else {
            throw RemoteLoaderError.url
        }
        
        var request = URLRequest(url: url)
        
        if let body = body, let encodedBody = try? JSONEncoder().encode(body) {
            request.httpMethod = "POST"
            request.httpBody = encodedBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let response = try? JSONDecoder().decode(U.self, from: data) {
                return response
            } else if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                throw RemoteLoaderError.api(error: apiError)
            }
        } catch {
            throw RemoteLoaderError.misc(error: error)
        }
        
        fatalError("Should not be hit")
    }
}

