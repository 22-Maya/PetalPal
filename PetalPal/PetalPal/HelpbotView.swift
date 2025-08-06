import SwiftUI
import Charts
import SwiftData
import FirebaseAuth
import FirebaseCore
import FirebaseAppCheck

// chat message model
struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(content: String, isUser: Bool, timestamp: Date = Date()) {
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

// ai chat view model
@MainActor
class AIChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiKey = AIConfig.geminiAPIKey
    private let baseURL = AIConfig.baseURL
    
    init() {
        //  welcome message
        messages.append(ChatMessage(
            content: "Hello! I'm PetalPal's AI assistant. I can help you with plant care, watering schedules, troubleshooting, and gardening tips. What would you like to know about your plants?",
            isUser: false
        ))
    }
    
    func sendMessage(_ message: String) {
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        //  user message
        let userMessage = ChatMessage(content: message, isUser: true)
        messages.append(userMessage)
        
        Task {
            await generateResponse(for: message)
        }
    }
    
    private func generateResponse(for userMessage: String) async {
        isLoading = true
        errorMessage = nil
        
        // context
        let systemPrompt = """
        You are PetalPal's AI assistant, a knowledgeable plant care expert. You help users with plant care questions.
        
        RESPONSE GUIDELINES:
        - Keep responses CONCISE (2-4 sentences max)
        - Use bullet points or numbered lists when helpful
        - Be direct and actionable
        - Use a friendly, encouraging tone
        - Focus on practical advice users can implement immediately
        
        FORMATTING:
        - Use emojis sparingly but effectively (🌱 💧 ☀️ 🐛)
        - Break up text with line breaks for readability
        - Use bold formatting for key points when helpful
        - Keep paragraphs short (1-2 sentences)
        
        If you're unsure about something, briefly recommend consulting a local garden center.
        """
        
        let prompt = "\(systemPrompt)\n\nUser question: \(userMessage)"
        
        do {
            let response = try await callGeminiAPI(prompt: prompt)
            
            if let aiMessage = response {
                messages.append(ChatMessage(content: aiMessage, isUser: false))
            } else {
                errorMessage = "Unable to generate response. Please try again."
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func callGeminiAPI(prompt: String) async throws -> String? {
        //  different model endpoints if one fails
        let modelEndpoints = [
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent",
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent",
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.0-pro:generateContent"
        ]
        
        for endpoint in modelEndpoints {
            guard let url = URL(string: "\(endpoint)?key=\(apiKey)") else {
                continue
            }
            
            print("🌱 Trying endpoint: \(endpoint)")
            
            let requestBody: [String: Any] = [
                "contents": [
                    [
                        "parts": [
                            ["text": prompt]
                        ]
                    ]
                ],
                "generationConfig": [
                    "temperature": 0.7,
                    "topK": 40,
                    "topP": 0.95,
                    "maxOutputTokens": 300,
                    "stopSequences": ["\n\n\n", "---", "###"]
                ]
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            //debug
            print("🌱 Making API request to Gemini...")
            print("🌱 URL: \(url)")
            print("🌱 API Key: \(String(apiKey.prefix(10)))...")
            print("🌱 Request Body: \(String(data: request.httpBody!, encoding: .utf8) ?? "Could not encode")")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("🌱 Error: Invalid HTTP response")
                continue
            }
            
            print("🌱 Response status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                if let candidates = json?["candidates"] as? [[String: Any]],
                   let firstCandidate = candidates.first,
                   let content = firstCandidate["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let firstPart = parts.first,
                   let text = firstPart["text"] as? String {
                    print("🌱 Successfully received AI response")
                    return text
                }
            } else {
                let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("🌱 Error response for \(endpoint): \(errorString)")
            }
        }
        
        // If all endpoints fail, throw an error
        throw NSError(domain: "GeminiAPI", code: 404, userInfo: [
            NSLocalizedDescriptionKey: "No working Gemini model found. Please check your API key and project configuration."
        ])
    }
}


// chat bubble view
struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.tealShade))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
            } else {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.blueShade))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

// main helpbot view
struct HelpbotView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var chatViewModel = AIChatViewModel()
    @State private var messageText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                    // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(.tealShade))
                            .padding(.leading, 20)
                    }

                    Text("PetalPal")
                        .scaledFont("Prata-Regular", size: 28)
                        .foregroundColor(Color(.tealShade))
                        .padding(.leading, 5)
                    Spacer()
                }
                .frame(height: 56)
                .background(Color(.blueShade))
                
                    // chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(chatViewModel.messages) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
                            }
                            
                            if chatViewModel.isLoading {
                                HStack {
                                    HStack(spacing: 4) {
                                        ForEach(0..<3) { index in
                                            Circle()
                                                .fill(Color(.tealShade))
                                                .frame(width: 8, height: 8)
                                                .scaleEffect(chatViewModel.isLoading ? 1.2 : 0.8)
                                                .animation(
                                                    Animation.easeInOut(duration: 0.6)
                                                        .repeatForever()
                                                        .delay(Double(index) * 0.2),
                                                    value: chatViewModel.isLoading
                                                )
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(.blueShade))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .onChange(of: chatViewModel.messages.count) { _ in
                        if let lastMessage = chatViewModel.messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                    // error message
                if let errorMessage = chatViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                }
                
                    // input area
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 12) {
                        TextField("Ask about your plants...", text: $messageText, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isTextFieldFocused)
                            .disabled(chatViewModel.isLoading)
                            .onSubmit {
                                sendMessage()
                            }
                        
                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatViewModel.isLoading
                                    ? Color.gray
                                    : Color(.tealShade)
                                )
                                .clipShape(Circle())
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatViewModel.isLoading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.backgroundShade))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color(.backgroundShade))
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        chatViewModel.sendMessage(trimmedMessage)
        messageText = ""
        isTextFieldFocused = false
    }
}

#Preview {
    HelpbotView()
}
