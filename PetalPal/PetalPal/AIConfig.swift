import Foundation

// ai configuration
struct AIConfig {
    static let geminiAPIKey = "AIzaSyAkmAJeITK67weHdBq7PEKppM8XCpXeDpA"
    
    static let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent"
    
    // rate limiting 
    static let maxRequestsPerMinute = 15 
    static let maxTokensPerResponse = 1024
    
    // model parameters
    static let temperature = 0.7
    static let topK = 40
    static let topP = 0.95
}