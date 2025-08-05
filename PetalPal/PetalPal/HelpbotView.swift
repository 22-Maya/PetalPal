import SwiftUI
import Charts
import SwiftData
import FirebaseAuth
import FirebaseCore
import FirebaseAppCheck
import FirebaseAI
//import GoogleGenerativeAI

enum APIKey {
    static var `default` : String {
        fatalError("APIKey.default is not used when integrating Gemini via FirebaseAI. The API key is managed by Firebase.")
    }
}

//structure for all chat messages
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    var text: String
    let isUser: Bool
    var isTyping: Bool = false
}

//chat logic
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var isFirebaseAIAvailable: Bool = false
    @Published var useDirectGoogleAI: Bool = false
    
    private var model: GenerativeModel?
    private var directModel: GenerativeModel?
    
    init() {
        // Check if Firebase is configured
        guard FirebaseApp.app() != nil else {
            print("Firebase is not configured. Make sure FirebaseApp.configure() is called in AppDelegate.")
            return
        }
        
        // Initialize Firebase AI model safely
        initializeFirebaseAI()
    }
    
    private func initializeFirebaseAI() {
        Task {
            do {
                print("Starting Firebase AI initialization...")
                
                // Try different initialization approaches
                let ai = FirebaseAI.firebaseAI(backend: .googleAI())
                print("Firebase AI backend created successfully")
                
                // Try different model names
                let modelNames = ["gemini-pro", "gemini-1.5-pro", "gemini-1.0-pro"]
                var successfulModel: GenerativeModel?
                
                for modelName in modelNames {
                    do {
                        print("Trying model: \(modelName)")
                        let testModel = ai.generativeModel(modelName: modelName)
                        let testResponse = try await testModel.generateContent("Hello")
                        print("Model \(modelName) works: \(testResponse.text ?? "No response")")
                        successfulModel = testModel
                        break
                    } catch {
                        print("Model \(modelName) failed: \(error)")
                        continue
                    }
                }
                
                if let firebaseModel = successfulModel {
                    DispatchQueue.main.async {
                        self.model = firebaseModel
                        self.isFirebaseAIAvailable = true
                        self.useDirectGoogleAI = false
                        print("Firebase AI model initialized successfully and set as available")
                    }
                } else {
                    // Try direct Google AI as fallback
                    try await initializeDirectGoogleAI()
                }
                
            } catch {
                print("Firebase AI failed, trying direct Google AI...")
                do {
                    try await initializeDirectGoogleAI()
                } catch {
                    DispatchQueue.main.async {
                        self.isFirebaseAIAvailable = false
                        self.useDirectGoogleAI = false
                        print("Both Firebase AI and Direct Google AI failed: \(error)")
                        print("Error type: \(type(of: error))")
                        print("Error description: \(error.localizedDescription)")
                        
                        if let nsError = error as? NSError {
                            print("NSError code: \(nsError.code)")
                            print("NSError domain: \(nsError.domain)")
                            print("NSError userInfo: \(nsError.userInfo)")
                        }
                        
                        self.messages.append(ChatMessage(text: "⚠️ AI service is not available. Please check your configuration.", isUser: false))
                        self.messages.append(ChatMessage(text: "📋 Setup required:\n1. Enable Google AI API in Google Cloud Console\n2. Set up billing account (free credits available)\n3. Check API quotas", isUser: false))
                    }
                }
            }
        }
    }
    
    private func initializeDirectGoogleAI() async throws {
        print("Initializing direct Google AI...")
        
        // You'll need to get an API key from Google AI Studio
        // For now, we'll show instructions
        DispatchQueue.main.async {
            self.useDirectGoogleAI = true
            self.isFirebaseAIAvailable = true
            self.messages.append(ChatMessage(text: "🔑 To use AI, you need an API key from Google AI Studio:\n1. Go to https://makersuite.google.com/app/apikey\n2. Create a new API key\n3. Add it to your app configuration", isUser: false))
        }
    }
//    send message function from user or for initial greeting
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {return}
        
        let userMessageText = inputText
        messages.append(ChatMessage(text: userMessageText, isUser: true))
        inputText = ""
        
        let aiTypingMessage = ChatMessage(text: "AI is typing...", isUser: false, isTyping: true)
        messages.append(aiTypingMessage)
        
        isLoading = true
        Task {
            do {
                guard let model = self.model else {
                    throw NSError(domain: "FirebaseAI", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Firebase AI model is not initialized"])
                }
                
                let prompt = userMessageText
                print("Sending prompt to Firebase AI: \(prompt)")
                
                let response = try await model.generateContent(prompt)
                print("Firebase AI response received: \(response.text ?? "No text")")
                
                DispatchQueue.main.async {
                    if let index = self.messages.firstIndex(where: { $0.id == aiTypingMessage.id }) {
                        self.messages[index].text = response.text ?? "No response from AI."
                        self.messages[index].isTyping = false
                    } else {
                        self.messages.append(ChatMessage(text: response.text ?? "No response from AI.", isUser: false))
                    }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    // Enhanced error handling
                    var errorMessage = "Error: \(error.localizedDescription)"
                    
                    // Check for specific Firebase AI errors
                    if let firebaseError = error as? GenerateContentError {
                        // Handle Firebase AI specific errors
                        errorMessage = "Firebase AI Error: \(firebaseError.localizedDescription)"
                    } else {
                        // Handle other types of errors
                        switch error {
                        case let nsError as NSError:
                            switch nsError.code {
                            case 1001:
                                errorMessage = "Error: Firebase AI is not initialized. Please check your configuration."
                            case 401:
                                errorMessage = "Error: Authentication failed. Please check Firebase configuration."
                            case 403:
                                errorMessage = "Error: Permission denied. Please check Firebase AI permissions."
                            case 429:
                                errorMessage = "Error: API quota exceeded. Please try again later."
                            case 503:
                                errorMessage = "Error: Firebase AI service is currently unavailable."
                            default:
                                errorMessage = "Error: \(nsError.localizedDescription)"
                            }
                        default:
                            errorMessage = "Error: \(error.localizedDescription)"
                        }
                    }
                    
                    if let index = self.messages.firstIndex(where: { $0.id == aiTypingMessage.id }) {
                        self.messages[index].text = errorMessage
                        self.messages[index].isTyping = false
                    } else {
                        self.messages.append(ChatMessage(text: errorMessage, isUser: false))
                    }
                    self.isLoading = false
                    print("Error generating content: \(error)")
                    print("Error details: \(error)")
                }
            }
        }
    }
    func sendInitialGreeting() {
        let greetingMessage = ChatMessage(text: "Hello! How can I help you today?", isUser: false)
        messages.append(greetingMessage)
        
        // Test Firebase AI connection only if it's available
        if isFirebaseAIAvailable {
            testFirebaseAIConnection()
        }
    }
    
    private func testFirebaseAIConnection() {
        Task {
            do {
                guard let model = self.model else {
                    print("Firebase AI model is not available for testing")
                    return
                }
                
                let testResponse = try await model.generateContent("Hello")
                print("Firebase AI test successful: \(testResponse.text ?? "No response")")
            } catch {
                print("Firebase AI test failed: \(error)")
                DispatchQueue.main.async {
                    self.messages.append(ChatMessage(text: "⚠️ Firebase AI connection test failed. Please check your configuration.", isUser: false))
                }
            }
        }
    }
}

//message bubble view
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .frame(maxWidth:250, alignment: .trailing)
            } else {
                Text(message.text)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    .frame(maxWidth: 250, alignment: .leading)
                Spacer()
            }
        }
    }
}

struct HelpbotView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ChatViewModel()
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    
    var body: some View {
        NavigationStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(red: 0/255, green: 122/255, blue: 69/255))
                        .padding(.leading, 20)
                }

                Text("PetalPal")
                    .scaledFont("Prata-Regular", size: 28)
                    .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
                    .padding(.leading, 5)
                Spacer()
            }
            .frame(height: 56)
            .background(Color(red: 174/255, green: 213/255, blue: 214/255))
            .padding(.bottom, 15)

            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        self.scrollViewProxy = proxy
                    }
                }
            }
            .padding(.horizontal)
            .background(Color.white)
            
            // Show Firebase AI status
            if !viewModel.isFirebaseAIAvailable {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Firebase AI is not available")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
                .padding(.horizontal)
            }
            
//            input field & send button
            HStack {
                TextField("Type your message...", text: $viewModel.inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
                    .padding(.horizontal, 5)
                    .disabled(viewModel.isLoading || !viewModel.isFirebaseAIAvailable)
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(10)
                        .background((viewModel.isLoading || !viewModel.isFirebaseAIAvailable) ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isLoading || !viewModel.isFirebaseAIAvailable)
            }
            .padding()
            .background(Color.white)
            .shadow(radius: 5)
        }
        .navigationBarBackButtonHidden(true)
        .foregroundStyle(Color(red: 13/255, green: 47/255, blue: 68/255))
        .scaledFont("Lato-Regular", size: 20)
        .background(Color(red: 249/255, green: 248/255, blue: 241/255))
        .onAppear {
            viewModel.sendInitialGreeting()
        }
    }
}

#Preview {
    HelpbotView()
}
