import Foundation

enum RemoteLoaderError: Error {
    case url
    case data
    case api(error: APIError)
    case misc(error: Error)
}

final class RemoteLoader {
    
    static let baseURL = "VAPP_BASE_URL"
        
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
    
    static func fetchData(url: String, authToken: String? = nil, completion: @escaping ((Result<Data, RemoteLoaderError>) -> Void)) {
        guard let url = URL(string: url) else {
            completion(.failure(.url))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(.misc(error: error!)))
                return
            }
            
            if let data = data {
                completion(.success(data))
                return
            }
        }.resume()
    }
    
    // Source: https://github.com/donnywals/MultipartRequestURLSession
    static func uploadImage(authToken: String,
                            body: Data,
                            completion: @escaping ((Result<Image.Response, RemoteLoaderError>) -> Void)) {
        guard let url = URL(string: RemoteLoader.baseURL + Image.path) else {
            completion(.failure(.url))
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let httpBody = NSMutableData()
        
        httpBody.append(convertFileData(fieldName: "image",
                                        fileName: "image",
                                        mimeType: "image/jpeg",
                                        fileData: body,
                                        using: boundary))
        httpBody.appendString("--\(boundary)--")
        
        request.httpBody = httpBody as Data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(.misc(error: error!)))
                return
            }
            
            if let data = data {
                if let response = try? JSONDecoder().decode(Image.Response.self, from: data) {
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
    
    private static func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
    }
}
