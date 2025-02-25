//
//  ContentView.swift
//  GeminiAI
//
//  Created by Bhumika Patel on 25/02/25.
//

//import SwiftUI
//import GoogleGenerativeAI
//
//struct ContentView: View {
//    @State private var textInput = ""
//    @State private var response: LocalizedStringKey = "Hello! How can I help you today?"
//
//    @State private var isThinking = false
//    let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
//
//    var body: some View {
//        VStack(alignment: .leading) {
//
//            ScrollView {
//                VStack {
//                    Text(response)
//                        .font(.system(.title, design: .rounded, weight: .medium))
//                        .opacity(isThinking ? 0.2 : 1.0)
//                }
//            }
//            .contentMargins(.horizontal, 15, for: .scrollContent)
//
//            Spacer()
//
//            HStack {
//
//                TextField("Type your message here", text: $textInput)
//                    .textFieldStyle(.plain)
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                    .onSubmit {
//                           sendMessage()
//                       }
//
//            }
//            .padding(.horizontal)
//        }
//    }
//    func sendMessage() {
//        response = "Thinking..."
//
//        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
//            isThinking.toggle()
//        }
//
//        Task {
//            do {
//                let generatedResponse = try await model.generateContent(textInput)
//
//                guard let text = generatedResponse.text else  {
//                    textInput = "Sorry, Gemini got some problems.\nPlease try again later."
//                    return
//                }
//
//                textInput = ""
//                response = LocalizedStringKey(text)
//
//                isThinking.toggle()
//            } catch {
//                response = "Something went wrong!\n\(error.localizedDescription)"
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
//enum APIKey {
//  // Fetch the API key from `GenerativeAI-Info.plist`
//  static var `default`: String {
//
//    guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist")
//    else {
//      fatalError("Couldn't find file 'GenerativeAI-Info.plist'.")
//    }
//
//    let plist = NSDictionary(contentsOfFile: filePath)
//
//    guard let value = plist?.object(forKey: "API_KEY") as? String else {
//      fatalError("Couldn't find key 'API_KEY' in 'GenerativeAI-Info.plist'.")
//    }
//
//    if value.starts(with: "_") {
//      fatalError(
//        "Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key."
//      )
//    }
//
//    return value
//  }
//}
import SwiftUI
import GoogleGenerativeAI

struct ContentView: View {
    @State private var textInput = ""
    @State private var response: String = "Hello! How can I help you today?"
    @State private var isThinking = false

    private let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text(response)
                        .font(.system(.title2, design: .rounded))
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .opacity(isThinking ? 0.5 : 1.0)
                }
            }
            .padding(.horizontal)

            Spacer()

            HStack {
                TextField("Type your message here...", text: $textInput)
                    .padding()
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .submitLabel(.send)
                    .onSubmit {
                        sendMessage()
                    }

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .disabled(textInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
    }

    private func sendMessage() {
        guard !textInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        response = "Thinking..."
        isThinking = true

        Task {
            do {
                let generatedResponse = try await model.generateContent(textInput)
                if let text = generatedResponse.text {
                    DispatchQueue.main.async {
                        response = text
                        textInput = ""
                        isThinking = false
                    }
                } else {
                    throw NSError(domain: "AIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from Gemini AI."])
                }
            } catch {
                DispatchQueue.main.async {
                    response = "Something went wrong!\n\(error.localizedDescription)"
                    isThinking = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

enum APIKey {
    static var `default`: String {
        guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist") else {
            print("Error: Missing 'GenerativeAI-Info.plist'")
            return "" // Return empty string to prevent fatal error
        }

        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String, !value.isEmpty else {
            print("Error: Missing or empty API_KEY in plist")
            return "" // Prevent app from crashing
        }

        return value
    }
}
