import Foundation
import SwiftUI

@MainActor
public class FlexAIViewModel: ObservableObject {
    private nonisolated let client: FlexAIClient
    private let defaultChatModel: String
    private let defaultSpeechModel: String
    
    @Published public var isLoading = false
    @Published public var error: Error?
    @Published public var models: [Model] = []
    @Published public var chatMessages: [Message] = []
    @Published public var generatedImages: [ImageResponse.ImageData] = []
    
    public init(
        baseURL: URL = URL(string: "https://localhost/v1")!,
        apiKey: String,
        defaultChatModel: String = "gpt-3.5-turbo",
        defaultSpeechModel: String = "tts-1"
    ) {
        self.client = FlexAIClient(baseURL: baseURL, apiKey: apiKey)
        self.defaultChatModel = defaultChatModel
        self.defaultSpeechModel = defaultSpeechModel
    }
    
    // MARK: - Models
    
    public func fetchModels() async {
        isLoading = true
        error = nil
        
        do {
            let response = try await client.listModels()
            models = response.data
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    // MARK: - Chat
    
    public func sendMessage(_ content: String, role: String = "user", model: String? = nil) async {
        let message = Message(role: role, content: content)
        chatMessages.append(message)
        
        let request = ChatCompletionRequest(
            model: model ?? defaultChatModel,
            messages: chatMessages,
            temperature: 0.7
        )
        
        isLoading = true
        error = nil
        
        do {
            let response = try await client.createChatCompletion(request: request)
            if let assistantMessage = response.choices.first?.message {
                chatMessages.append(assistantMessage)
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    public func streamMessage(_ content: String, role: String = "user", model: String? = nil) async {
        let message = Message(role: role, content: content)
        chatMessages.append(message)
        
        let request = ChatCompletionRequest(
            model: model ?? defaultChatModel,
            messages: chatMessages,
            temperature: 0.7,
            stream: true
        )
        
        isLoading = true
        error = nil
        
        do {
            try await client.createStreamingChatCompletion(request: request) { [weak self] response in
                guard let self = self else { return }
                Task { @MainActor in
                    if let message = response.choices.first?.message {
                        if let lastMessage = self.chatMessages.last,
                           lastMessage.role == "assistant" {
                            // Append to existing message
                            let updatedContent = lastMessage.content + message.content
                            self.chatMessages[self.chatMessages.count - 1] = Message(
                                role: "assistant",
                                content: updatedContent
                            )
                        } else {
                            // Create new message
                            self.chatMessages.append(message)
                        }
                    }
                }
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    // MARK: - Images
    
    public func generateImage(prompt: String, model: String = "dall-e-3") async {
        let request = ImageGenerationRequest(
            prompt: prompt,
            model: model,
            n: 1,
            quality: "standard",
            responseFormat: "url",
            size: "1024x1024",
            style: "natural"
        )
        
        isLoading = true
        error = nil
        
        do {
            let response = try await client.createImage(request: request)
            generatedImages = response.data
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    // MARK: - Audio
    
    public func generateSpeech(text: String, voice: String = "alloy", model: String? = nil) async -> Data? {
        let request = SpeechRequest(
            model: model ?? defaultSpeechModel,
            input: text,
            voice: voice
        )
        
        isLoading = true
        error = nil
        
        do {
            let audioData = try await client.createSpeech(request: request)
            isLoading = false
            return audioData
        } catch {
            self.error = error
            isLoading = false
            return nil
        }
    }
    
    public func transcribeAudio(audioData: Data, language: String? = nil, model: String = "whisper-1") async -> String? {
        let request = TranscriptionRequest(
            file: audioData,
            model: model,
            prompt: nil,
            responseFormat: "text",
            temperature: 0.0,
            language: language
        )
        
        isLoading = true
        error = nil
        
        do {
            let transcript = try await client.createTranscription(request: request)
            isLoading = false
            return transcript
        } catch {
            self.error = error
            isLoading = false
            return nil
        }
    }
} 
