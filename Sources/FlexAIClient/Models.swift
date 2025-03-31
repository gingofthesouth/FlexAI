import Foundation

// MARK: - Common Models

/// Base response structure for paginated lists
public struct ListResponse<T: Codable & Sendable>: Codable, Sendable {
    public let object: String
    public let data: [T]
    public let hasMore: Bool
    public let firstId: String?
    public let lastId: String?
    
    enum CodingKeys: String, CodingKey {
        case object
        case data
        case hasMore = "has_more"
        case firstId = "first_id"
        case lastId = "last_id"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        object = try container.decode(String.self, forKey: .object)
        data = try container.decode([T].self, forKey: .data)
        hasMore = try container.decodeIfPresent(Bool.self, forKey: .hasMore) ?? false
        firstId = try container.decodeIfPresent(String.self, forKey: .firstId)
        lastId = try container.decodeIfPresent(String.self, forKey: .lastId)
    }
}

/// Model information
public struct Model: Codable, Identifiable, Sendable {
    public let id: String
    public let object: String
    public let created: Int
    public let ownedBy: String
    public let permission: [Permission]
    public let root: String?
    public let parent: String?

    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case ownedBy = "owned_by"
        case permission
        case root
        case parent
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        object = try container.decode(String.self, forKey: .object)
        ownedBy = try container.decode(String.self, forKey: .ownedBy)
        created = try container.decodeIfPresent(Int.self, forKey: .created) ?? 0
        permission = try container.decodeIfPresent([Permission].self, forKey: .permission) ?? []
        root = try container.decodeIfPresent(String.self, forKey: .root)
        parent = try container.decodeIfPresent(String.self, forKey: .parent)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(object, forKey: .object)
        try container.encode(created, forKey: .created)
        try container.encode(ownedBy, forKey: .ownedBy)
        try container.encode(permission, forKey: .permission)
        try container.encodeIfPresent(root, forKey: .root)
        try container.encodeIfPresent(parent, forKey: .parent)
    }

    public init(id: String, object: String, created: Int, ownedBy: String, permission: [Permission], root: String?, parent: String?) {
        self.id = id
        self.object = object
        self.created = created
        self.ownedBy = ownedBy
        self.permission = permission
        self.root = root
        self.parent = parent
    }
}

/// Model permission information
public struct Permission: Codable, Sendable {
    public let id: String
    public let object: String
    public let created: Int
    public let allowCreateEngine: Bool
    public let allowSampling: Bool
    public let allowLogprobs: Bool
    public let allowSearchIndices: Bool
    public let allowView: Bool
    public let allowFineTuning: Bool
    public let organization: String
    public let group: String?
    public let isBlocking: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case allowCreateEngine = "allow_create_engine"
        case allowSampling = "allow_sampling"
        case allowLogprobs = "allow_logprobs"
        case allowSearchIndices = "allow_search_indices"
        case allowView = "allow_view"
        case allowFineTuning = "allow_fine_tuning"
        case organization
        case group
        case isBlocking = "is_blocking"
    }
}

/// Usage information for API calls
public struct Usage: Codable, Sendable {
    public let promptTokens: Int
    public let completionTokens: Int?
    public let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - Audio Models

/// Speech generation request
public struct SpeechRequest: Codable {
    public let model: String
    public let input: String
    public let voice: String
    public let responseFormat: String?
    public let speed: Double?
    
    enum CodingKeys: String, CodingKey {
        case model
        case input
        case voice
        case responseFormat = "response_format"
        case speed
    }
    
    public init(model: String, input: String, voice: String, responseFormat: String? = nil, speed: Double? = nil) {
        self.model = model
        self.input = input
        self.voice = voice
        self.responseFormat = responseFormat
        self.speed = speed
    }
}

/// Transcription request
public struct TranscriptionRequest: Codable {
    public let file: Data
    public let model: String
    public let prompt: String?
    public let responseFormat: String?
    public let temperature: Double?
    public let language: String?
    
    enum CodingKeys: String, CodingKey {
        case file
        case model
        case prompt
        case responseFormat = "response_format"
        case temperature
        case language
    }
    
    public init(
        file: Data,
        model: String,
        prompt: String? = nil,
        responseFormat: String? = nil,
        temperature: Double? = nil,
        language: String? = nil
    ) {
        self.file = file
        self.model = model
        self.prompt = prompt
        self.responseFormat = responseFormat
        self.temperature = temperature
        self.language = language
    }
}

/// Translation request
public struct TranslationRequest: Codable {
    public let file: Data
    public let model: String
    public let prompt: String?
    public let responseFormat: String?
    public let temperature: Double?
    
    enum CodingKeys: String, CodingKey {
        case file
        case model
        case prompt
        case responseFormat = "response_format"
        case temperature
    }
}

// MARK: - Chat Models

/// Chat completion request
public struct ChatCompletionRequest: Codable {
    public var model: String
    public var messages: [Message]
    public var temperature: Double?
    public var topP: Double?
    public var n: Int?
    public var stream: Bool?
    public var stop: [String]?
    public var maxTokens: Int?
    public var presencePenalty: Double?
    public var frequencyPenalty: Double?
    public var logitBias: [String: Int]?
    public var user: String?
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case topP = "top_p"
        case n
        case stream
        case stop
        case maxTokens = "max_tokens"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
        case logitBias = "logit_bias"
        case user
    }
    
    public init(
        model: String,
        messages: [Message],
        temperature: Double? = nil,
        topP: Double? = nil,
        n: Int? = nil,
        stream: Bool? = nil,
        stop: [String]? = nil,
        maxTokens: Int? = nil,
        presencePenalty: Double? = nil,
        frequencyPenalty: Double? = nil,
        logitBias: [String: Int]? = nil,
        user: String? = nil
    ) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.topP = topP
        self.n = n
        self.stream = stream
        self.stop = stop
        self.maxTokens = maxTokens
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.logitBias = logitBias
        self.user = user
    }
}

/// Chat message
public struct Message: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public let role: String
    public let content: String
    public let name: String?
    
    public init(id: UUID = UUID(), role: String, content: String, name: String? = nil) {
        self.id = id
        self.role = role
        self.content = content
        self.name = name
    }
    
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}

/// Chat completion response
public struct ChatCompletionResponse: Codable, Sendable {
    public let id: String
    public let object: String
    public let created: Int
    public let model: String
    public let choices: [Choice]
    public let usage: Usage?
    
    public struct Choice: Codable, Sendable {
        public let index: Int
        public let message: Message
        public let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }
}

// MARK: - Image Models

/// Image generation request
public struct ImageGenerationRequest: Codable {
    public let prompt: String
    public let model: String?
    public let n: Int?
    public let quality: String?
    public let responseFormat: String?
    public let size: String?
    public let style: String?
    public let user: String?
    
    enum CodingKeys: String, CodingKey {
        case prompt
        case model
        case n
        case quality
        case responseFormat = "response_format"
        case size
        case style
        case user
    }
    
    public init(
        prompt: String,
        model: String? = nil,
        n: Int? = nil,
        quality: String? = nil,
        responseFormat: String? = nil,
        size: String? = nil,
        style: String? = nil,
        user: String? = nil
    ) {
        self.prompt = prompt
        self.model = model
        self.n = n
        self.quality = quality
        self.responseFormat = responseFormat
        self.size = size
        self.style = style
        self.user = user
    }
}

/// Image response
public struct ImageResponse: Codable, Sendable {
    public let created: Int
    public let data: [ImageData]
    
    public struct ImageData: Codable, Sendable {
        public let url: String?
        public let b64Json: String?
        public let revisedPrompt: String?
        
        enum CodingKeys: String, CodingKey {
            case url
            case b64Json = "b64_json"
            case revisedPrompt = "revised_prompt"
        }
    }
} 
