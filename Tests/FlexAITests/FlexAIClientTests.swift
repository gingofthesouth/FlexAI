import XCTest
@testable import FlexAIClient

final class FlexAIClientTests: XCTestCase {
    var client: FlexAIClient!
    
    override func setUp() {
        super.setUp()
        client = FlexAIClient(baseURL: URL(string: "https://api.test.com/v1")!, apiKey: "test-key")
    }
    
    override func tearDown() {
        client = nil
        super.tearDown()
    }
    
    func testClientInitialization() {
        XCTAssertNotNil(client)
    }
    
    func testChatCompletionRequest() async throws {
        let request = ChatCompletionRequest(
            model: "gpt-4",
            messages: [Message(role: "user", content: "Hello")],
            temperature: 0.7
        )
        
        XCTAssertEqual(request.model, "gpt-4")
        XCTAssertEqual(request.messages.count, 1)
        XCTAssertEqual(request.messages.first?.role, "user")
        XCTAssertEqual(request.messages.first?.content, "Hello")
        XCTAssertEqual(request.temperature, 0.7)
    }
    
    func testSpeechRequest() {
        let request = SpeechRequest(
            model: "gpt-4o-mini-tts",
            input: "Hello, world!",
            voice: "alloy"
        )
        
        XCTAssertEqual(request.model, "gpt-4o-mini-tts")
        XCTAssertEqual(request.input, "Hello, world!")
        XCTAssertEqual(request.voice, "alloy")
    }
    
    func testImageGenerationRequest() {
        let request = ImageGenerationRequest(
            prompt: "A beautiful sunset",
            n: 1,
            size: "1024x1024"
        )
        
        XCTAssertEqual(request.prompt, "A beautiful sunset")
        XCTAssertEqual(request.n, 1)
        XCTAssertEqual(request.size, "1024x1024")
    }
} 
