import Foundation

// MARK: - Endpoints

public enum FlexAIEndpoint {
    // Models
    case listModels
    case retrieveModel(id: String)
    case deleteModel(id: String)
    
    // Chat
    case createChatCompletion(request: ChatCompletionRequest)
    
    // Audio
    case createSpeech(request: SpeechRequest)
    case createTranscription(request: TranscriptionRequest)
    case createTranslation(request: TranslationRequest)
    
    // Images
    case createImage(request: ImageGenerationRequest)
    case createImageEdit(request: ImageGenerationRequest)
    case createImageVariation(request: ImageGenerationRequest)
}

extension FlexAIEndpoint: Endpoint {
    public var path: String {
        switch self {
        case .listModels:
            return "models"
        case .retrieveModel(let id):
            return "models/\(id)"
        case .deleteModel(let id):
            return "models/\(id)"
        case .createChatCompletion:
            return "chat/completions"
        case .createSpeech:
            return "audio/speech"
        case .createTranscription:
            return "audio/transcriptions"
        case .createTranslation:
            return "audio/translations"
        case .createImage:
            return "images/generations"
        case .createImageEdit:
            return "images/edits"
        case .createImageVariation:
            return "images/variations"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .listModels:
            return .get
        case .retrieveModel:
            return .get
        case .deleteModel:
            return .delete
        case .createChatCompletion,
             .createSpeech,
             .createTranscription,
             .createTranslation,
             .createImage,
             .createImageEdit,
             .createImageVariation:
            return .post
        }
    }
    
    public var body: Encodable? {
        switch self {
        case .createChatCompletion(let request):
            return request
        case .createSpeech(let request):
            return request
        case .createTranscription(let request):
            return request
        case .createTranslation(let request):
            return request
        case .createImage(let request),
             .createImageEdit(let request),
             .createImageVariation(let request):
            return request
        default:
            return nil
        }
    }
    
    public var queryItems: [URLQueryItem]? {
        return nil
    }
}

// MARK: - API Extensions

extension FlexAIClient {
    // MARK: Models
    
    public func listModels() async throws -> ListResponse<Model> {
        return try await self.request(.listModels)
    }
    
    public func retrieveModel(id: String) async throws -> Model {
        return try await self.request(.retrieveModel(id: id))
    }
    
    public func deleteModel(id: String) async throws -> Model {
        return try await self.request(.deleteModel(id: id))
    }
    
    // MARK: Chat
    
    public func createChatCompletion(request: ChatCompletionRequest) async throws -> ChatCompletionResponse {
        return try await self.request(.createChatCompletion(request: request))
    }
    
    public func createStreamingChatCompletion(request: ChatCompletionRequest, onReceive: @escaping @Sendable (ChatCompletionResponse) -> Void) async throws {
        var streamingRequest = request
        streamingRequest.stream = true
        try await self.streamRequest(.createChatCompletion(request: streamingRequest)) { data in
            if let response = try? JSONDecoder().decode(ChatCompletionResponse.self, from: data) {
                onReceive(response)
            }
        }
    }
    
    // MARK: Audio
    
    public func createSpeech(request: SpeechRequest) async throws -> Data {
        return try await self.request(.createSpeech(request: request))
    }
    
    public func createTranscription(request: TranscriptionRequest) async throws -> String {
        return try await self.request(.createTranscription(request: request))
    }
    
    public func createTranslation(request: TranslationRequest) async throws -> String {
        return try await self.request(.createTranslation(request: request))
    }
    
    // MARK: Images
    
    public func createImage(request: ImageGenerationRequest) async throws -> ImageResponse {
        return try await self.request(.createImage(request: request))
    }
    
    public func createImageEdit(request: ImageGenerationRequest) async throws -> ImageResponse {
        return try await self.request(.createImageEdit(request: request))
    }
    
    public func createImageVariation(request: ImageGenerationRequest) async throws -> ImageResponse {
        return try await self.request(.createImageVariation(request: request))
    }
} 
