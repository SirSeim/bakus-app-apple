import SwiftUI

struct LoginPayload: Codable {
    var username: String
    var password: String
}

struct LinkPayload: Codable {
    var magnetLink: String
}

struct LoginSuccess: Codable {
    var expiry: Date
    var token: String
}

struct ErrorResponse: Codable {
    var detail: String
}

enum CallError: Error {
    case unknown
    case notLoggedIn
    case unexpectedRequest
    case unexpectedResponse
    case badRequest
    case badUrl
    case unauthorized
    case serverError
}

enum DateError: String, Error {
    case invalidDate
}

struct EmptyPayload: Codable {}

class ApiManager {
    let host = "https://bakus.seim.io"
    
    func loggedIn() -> Bool {
        guard let token = token() else {
            return false
        }
        return token.count > 0
    }
    
    func setAuth(token: String) {
        KeychainHelper.standard.save(item: token, service: "bakus", account: "auth-token")
    }
    
    func token() -> String? {
        return KeychainHelper.standard.read(service: "bakus", account: "auth-token", type: String.self)
    }
    
    func clearAuth() {
        KeychainHelper.standard.delete(service: "bakus", account: "auth-token")
    }
    
    func getURLSession() -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpAdditionalHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
        ]
        if loggedIn() {
            sessionConfig.httpAdditionalHeaders!["Authorization"] = "Token \(token()!)"
        }
        return URLSession(configuration: sessionConfig)
    }
    
    func getResponseData<T: Decodable>(_ type: T.Type, from: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            throw DateError.invalidDate
        })
        return try decoder.decode(type, from: from)
    }
    
    func formatError(response: HTTPURLResponse, data: Data) -> CallError {
        print("error statusCode \(response.statusCode):", String(data: data, encoding: .utf8) ?? "")
        let decodedError: ErrorResponse
        do {
            decodedError = try self.getResponseData(ErrorResponse.self, from: data)
        } catch let error {
            print("error decoding error response \(error)")
            return CallError.unexpectedResponse
        }
        
        let errorType: CallError
        switch response.statusCode {
        case 400:
            errorType = .badRequest
        case 401:
            errorType = .unauthorized
        case 500:
            errorType = .serverError
        default:
            errorType = .unknown
        }
        print("error detail: \(decodedError.detail)")
        return errorType
    }
    
    func getData<T: Decodable>(urlString: String, ensureTokenSet: Bool = true) async throws -> T {
        guard let url = URL(string: "\(host)\(urlString)") else {
            print("error URL: \(urlString)")
            throw CallError.badUrl
        }
        
        if ensureTokenSet && !loggedIn() {
            throw CallError.notLoggedIn
        }
        
        let session = getURLSession()
        return try await withUnsafeThrowingContinuation { c in
            session.dataTask(with: url) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("could not format HttpResponse")
                    c.resume(throwing: CallError.unexpectedResponse)
                    return
                }
                
                guard let data = data else {
                    c.resume(throwing: CallError.unexpectedResponse)
                    return
                }
                if httpResponse.statusCode != 200 {
                    c.resume(throwing: self.formatError(response: httpResponse, data: data))
                    return
                }
                
                do {
                    c.resume(returning: try self.getResponseData(T.self, from: data))
                } catch let error {
                    print(error)
                    c.resume(throwing: CallError.unexpectedResponse)
                }
            }.resume()
        }
    }
    
    func createPostRequest<T: Encodable>(url: URL, data: T) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(data)
        } catch let error {
            print("error json serialize:", error)
            return nil
        }
        return request
    }
    
    func postData<T: Decodable, Y: Encodable>(urlString: String, data: Y, ensureTokenSet: Bool = true) async throws -> T {
        guard let url = URL(string: "\(host)\(urlString)") else {
            print("error URL: \(urlString)")
            throw CallError.badUrl
        }
        if ensureTokenSet && !loggedIn() {
            throw CallError.notLoggedIn
        }
        
        let session = getURLSession()
        guard let request = createPostRequest(url: url, data: data) else {
            throw CallError.unexpectedRequest
        }
        return try await withUnsafeThrowingContinuation { c in
            session.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("could not format HttpResponse")
                    c.resume(throwing: CallError.unexpectedResponse)
                    return
                }
                
                guard let data = data else {
                    c.resume(throwing: CallError.unexpectedResponse)
                    return
                }
                if httpResponse.statusCode != 200 {
                    c.resume(throwing: self.formatError(response: httpResponse, data: data))
                    return
                }
                
                do {
                    c.resume(returning: try self.getResponseData(T.self, from: data))
                } catch let error {
                    print(error)
                    c.resume(throwing: CallError.unexpectedResponse)
                }
            }.resume()
        }
    }
    
    func postDataWithoutResponse<T: Encodable>(urlString: String, data: T, ensureTokenSet: Bool = true) async throws -> Void {
        guard let url = URL(string: "\(host)\(urlString)") else {
            print("error URL: \(urlString)")
            throw CallError.badUrl
        }
        if ensureTokenSet && !loggedIn() {
            throw CallError.notLoggedIn
        }
        
        let session = getURLSession()
        guard let request = createPostRequest(url: url, data: data) else {
            throw CallError.unexpectedRequest
        }
        return try await withUnsafeThrowingContinuation { c in
            session.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("could not format HttpResponse")
                    c.resume(throwing: CallError.unexpectedResponse)
                    return
                }
                
                if httpResponse.statusCode != 204 {
                    guard let data = data else {
                        c.resume(throwing: CallError.unexpectedResponse)
                        return
                    }
                    c.resume(throwing: self.formatError(response: httpResponse, data: data))
                    return
                }
                c.resume()
            }.resume()
        }
    }
    
    func loadAdditions() async -> [Addition]? {
        do {
            let results: AdditionResults = try await getData(urlString: "/api/v1/addition/")
            return results.results
        } catch {
            print("failed to get additions \(error)")
            return nil
        }
    }
    
    func loadProfile() async -> Profile? {
        do {
            return try await getData(urlString: "/api/v1/auth/account/")
        } catch {
            print("failed to get profile: \(error)")
            return nil
        }
    }

    func addAddition(link: String) async -> Addition? {
        let payload = LinkPayload(magnetLink: link)
        do {
            return try await postData(urlString: "/api/v1/addition/", data: payload)
        } catch {
            print("failed to add addition: \(error)")
            return nil
        }
    }
    
    func authenticated() async -> Bool {
        do {
            let _: Profile = try await getData(urlString: "/api/v1/auth/account/")
            return true
        } catch {
            self.clearAuth()
            return false
        }
    }
    
    func login(username: String, password: String) async -> Void {
        let payload = LoginPayload(username: username, password: password)
        do {
            let result: LoginSuccess = try await postData(urlString: "/api/v1/auth/login/", data: payload, ensureTokenSet: false)
            setAuth(token: result.token)
        } catch {
            print("failed to login: \(error)")
        }
    }
    
    func logout() async -> Void {
        do {
            try await postDataWithoutResponse(urlString: "/api/v1/auth/logout/", data: EmptyPayload())
            print("logged out")
        } catch {
            print("failed to logout: \(error)")
        }
    }
}
