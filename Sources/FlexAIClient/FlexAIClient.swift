import Foundation

/// Main client for interacting with the FlexAI API
public class FlexAIClient: @unchecked Sendable {
    private let baseURL: URL
    private let apiKey: String
    private let session: URLSession
    
    public init(baseURL: URL = URL(string: "https://localhost/v1")!, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        self.session = URLSession(configuration: configuration)
    }
    
    /// Generic request method for making API calls
    func request<T: Decodable>(_ endpoint: FlexAIEndpoint) async throws -> T {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = endpoint.queryItems
        
        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    /// Stream request method for handling streaming responses
    func streamRequest(_ endpoint: FlexAIEndpoint, onReceive: @escaping @Sendable (Data) -> Void) async throws {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = endpoint.queryItems
        
        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (bytes, response) = try await session.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: Data())
        }
        
        for try await line in bytes.lines {
            if line.hasPrefix("data: "), let data = line.dropFirst(6).data(using: .utf8) {
                onReceive(data)
            }
        }
    }
}

/// HTTP Methods supported by the API
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"
}

/// Protocol defining an API endpoint
public protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Encodable? { get }
    var queryItems: [URLQueryItem]? { get }
}

/// API Errors that can occur
public enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case encodingError
    case decodingError
} 
