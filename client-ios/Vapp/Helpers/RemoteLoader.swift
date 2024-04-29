//
//  RemoteLoader.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 12/03/2024.
//

import Foundation

enum RemoteLoaderError: Error {
    case url
    case unknown
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
            } else {
                throw RemoteLoaderError.unknown
            }
        } catch {
            throw RemoteLoaderError.misc(error: error)
        }
    }
    
    static func multipart<U: Codable>(path: String,
                                      mimeType: String,
                                      authToken: String,
                                      data: Data) async throws -> U {
        
        guard let url = URL(string: baseURL + path) else {
            throw RemoteLoaderError.url
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let response = try? JSONDecoder().decode(U.self, from: data) {
                return response
            } else if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                throw RemoteLoaderError.api(error: apiError)
            } else {
                throw RemoteLoaderError.unknown
            }
        } catch {
            throw RemoteLoaderError.misc(error: error)
        }
    }
}

