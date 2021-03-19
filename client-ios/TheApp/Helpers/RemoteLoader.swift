import Foundation

enum RemoteLoaderError: Error {
    case url
    case data
    case api(error: APIError)
}

final class RemoteLoader {
    
    static let baseURL = ""
    
    static func load<T: Codable, U: Codable>(path: String,
                                             authToken: String? = nil,
                                             body: T?,
                                             responseType: U.Type,
                                             completion: @escaping ((Result<U, RemoteLoaderError>) -> Void)) {
        guard let url = URL(string: baseURL + path) else {
            completion(.failure(.url))
            return
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
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let response = try? JSONDecoder().decode(U.self, from: data) {
                    completion(.success(response))
                    return
                } else if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                    completion(.failure(.api(error: apiError)))
                    return
                }
            }
            completion(.failure(.data))
        }.resume()
    }
}
