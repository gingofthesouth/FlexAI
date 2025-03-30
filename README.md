# FlexAI Swift Client

A modern SwiftUI client for the OpenAI API. This package provides a clean and easy-to-use interface for interacting with OpenAI's services or apps such as LM Studio that implement an OpenAi-like API, including:

- Chat completions
- Image generation
- Text-to-speech and speech-to-text
- Model management

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.5+
- Xcode 13.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "your-repository-url", from: "1.0.0")
]
```

## Usage

### Initialize the Client

```swift
import FlexAIClient

let client = FlexAIClient(
    baseURL: URL(string: "https://your-api-endpoint.com/v1")!,
    apiKey: "your-api-key"
)
```

### Chat Completions

```swift
let view = ChatView(
    baseURL: URL(string: "https://your-api-endpoint.com/v1")!,
    apiKey: "your-api-key"
)
```

### Image Generation

```swift
let view = ImageGenerationView(
    baseURL: URL(string: "https://your-api-endpoint.com/v1")!,
    apiKey: "your-api-key"
)
```

### Text-to-Speech

```swift
let view = AudioView(
    baseURL: URL(string: "https://your-api-endpoint.com/v1")!,
    apiKey: "your-api-key"
)
```

### Using the Main View

The package provides a main view that includes all functionality in a tabbed interface:

```swift
let view = FlexAIMainView(
    baseURL: URL(string: "https://your-api-endpoint.com/v1")!,
    apiKey: "your-api-key"
)
```

## Features

### Chat
- Real-time streaming responses
- Message history
- Customizable model parameters
- Beautiful chat interface

### Image Generation
- Generate images from text prompts
- Support for multiple image sizes
- Grid view for generated images
- Image variations and edits

### Audio
- Text-to-speech conversion
- Multiple voice options
- Built-in audio player
- Speech-to-text transcription

## Security

Never hardcode your API key in your application. Instead, use secure storage methods or environment variables to manage sensitive credentials.

## License

This project is available under the MIT license. See the LICENSE file for more info. 
