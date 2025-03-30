import SwiftUI
import AVFoundation

// MARK: - Chat View

public struct ChatView: View {
    @StateObject private var viewModel: FlexAIViewModel
    @State private var messageText = ""
    @State private var isStreaming = false
    private let chatModel: String?
    
    public init(
        baseURL: URL = URL(string: "https://localhost/v1")!,
        apiKey: String,
        chatModel: String? = nil,
        defaultChatModel: String = "gpt-3.5-turbo"
    ) {
        self.chatModel = chatModel
        _viewModel = StateObject(wrappedValue: FlexAIViewModel(
            baseURL: baseURL,
            apiKey: apiKey,
            defaultChatModel: defaultChatModel
        ))
    }
    
    public var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.chatMessages, id: \.content) { message in
                        MessageView(message: message)
                    }
                }
                .padding()
            }
            
            Divider()
            
            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(viewModel.isLoading)
                
                Toggle("Stream", isOn: $isStreaming)
                    .toggleStyle(.button)
                    .disabled(viewModel.isLoading)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(messageText.isEmpty || viewModel.isLoading)
            }
            .padding()
        }
    }
    
    private func sendMessage() {
        let text = messageText
        messageText = ""
        
        Task {
            if isStreaming {
                await viewModel.streamMessage(text, model: chatModel)
            } else {
                await viewModel.sendMessage(text, model: chatModel)
            }
        }
    }
}

struct MessageView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.role == "assistant" {
                Spacer()
            }
            
            Text(message.content)
                .padding()
                .background(message.role == "user" ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                .cornerRadius(12)
            
            if message.role == "user" {
                Spacer()
            }
        }
    }
}

// MARK: - Image Generation View

public struct ImageGenerationView: View {
    @StateObject private var viewModel: FlexAIViewModel
    @State private var prompt = ""
    private let imageModel: String
    
    public init(
        baseURL: URL = URL(string: "https://localhost/v1")!,
        apiKey: String,
        imageModel: String = "dall-e-3"
    ) {
        self.imageModel = imageModel
        _viewModel = StateObject(wrappedValue: FlexAIViewModel(baseURL: baseURL, apiKey: apiKey))
    }
    
    public var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 16) {
                    ForEach(viewModel.generatedImages, id: \.url) { imageData in
                        if let urlString = imageData.url, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            HStack {
                TextField("Enter image prompt...", text: $prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(viewModel.isLoading)
                
                Button(action: generateImage) {
                    Image(systemName: "wand.and.stars")
                }
                .disabled(prompt.isEmpty || viewModel.isLoading)
            }
            .padding()
        }
    }
    
    private func generateImage() {
        let text = prompt
        prompt = ""
        
        Task {
            await viewModel.generateImage(prompt: text, model: imageModel)
        }
    }
}

// MARK: - Audio View

public struct AudioView: View {
    @StateObject private var viewModel: FlexAIViewModel
    @State private var text = ""
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    private let speechModel: String?
    private let transcriptionModel: String
    
    public init(
        baseURL: URL = URL(string: "https://localhost/v1")!,
        apiKey: String,
        speechModel: String? = nil,
        defaultSpeechModel: String = "tts-1",
        transcriptionModel: String = "whisper-1"
    ) {
        self.speechModel = speechModel
        self.transcriptionModel = transcriptionModel
        _viewModel = StateObject(wrappedValue: FlexAIViewModel(
            baseURL: baseURL,
            apiKey: apiKey,
            defaultSpeechModel: defaultSpeechModel
        ))
    }
    
    public var body: some View {
        VStack {
            TextField("Enter text to convert to speech...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(viewModel.isLoading)
                .padding()
            
            HStack {
                Button(action: generateSpeech) {
                    Label("Generate Speech", systemImage: "waveform")
                }
                .disabled(text.isEmpty || viewModel.isLoading)
                
                if audioPlayer != nil {
                    Button(action: togglePlayback) {
                        Label(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.fill" : "play.fill")
                    }
                }
            }
            .padding()
            
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
    
    private func generateSpeech() {
        Task {
            if let audioData = await viewModel.generateSpeech(text: text, model: speechModel) {
                audioPlayer = try? AVAudioPlayer(data: audioData)
                audioPlayer?.prepareToPlay()
            }
        }
    }
    
    private func togglePlayback() {
        if isPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
        isPlaying.toggle()
    }
}

// MARK: - Main View

public struct FlexAIMainView: View {
    private let baseURL: URL
    private let apiKey: String
    private let chatModel: String?
    private let imageModel: String
    private let speechModel: String?
    private let transcriptionModel: String
    
    public init(
        baseURL: URL = URL(string: "https://localhost/v1")!,
        apiKey: String,
        chatModel: String? = nil,
        defaultChatModel: String = "gpt-3.5-turbo",
        imageModel: String = "dall-e-3",
        speechModel: String? = nil,
        defaultSpeechModel: String = "tts-1",
        transcriptionModel: String = "whisper-1"
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.chatModel = chatModel
        self.imageModel = imageModel
        self.speechModel = speechModel
        self.transcriptionModel = transcriptionModel
    }
    
    public var body: some View {
        TabView {
            ChatView(
                baseURL: baseURL,
                apiKey: apiKey,
                chatModel: chatModel
            )
            .tabItem {
                Label("Chat", systemImage: "bubble.left.and.bubble.right")
            }
            
            ImageGenerationView(
                baseURL: baseURL,
                apiKey: apiKey,
                imageModel: imageModel
            )
            .tabItem {
                Label("Images", systemImage: "photo")
            }
            
            AudioView(
                baseURL: baseURL,
                apiKey: apiKey,
                speechModel: speechModel,
                transcriptionModel: transcriptionModel
            )
            .tabItem {
                Label("Audio", systemImage: "waveform")
            }
        }
    }
} 
