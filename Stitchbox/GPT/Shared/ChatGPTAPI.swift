//
//  ChatGPTAPI.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import Foundation
import GPTEncoder

class ChatGPTAPI: @unchecked Sendable {
    
    private let systemMessage: Message
    private let temperature: Double
    private let tokenManager: ChatGPTTokenManager
    private let apiKey: String
    //private var historyList = [Message]()
    private let urlSession = URLSession.shared
    private var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        return df
    }()
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    
    private var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
    

    init(apiKey: String, systemPrompt: String = "You are a helpful assistant", temperature: Double = 0.5) {
        self.apiKey = apiKey
        self.systemMessage = .init(role: "system", content: systemPrompt)
        self.temperature = temperature
        self.tokenManager = ChatGPTTokenManager(tokenizer: GPTEncoder())
    }
    
    private func generateMessages(from text: String) -> [Message] {
        let messages = [systemMessage] + tokenManager.historyList + [Message(role: "user", content: text)]
        return messages
    }

    
    private func jsonBody(text: String, stream: Bool = true) throws -> Data {
        let request = Request(model: global_gpt, temperature: temperature,
                              messages: generateMessages(from: text), stream: stream)
        return try JSONEncoder().encode(request)
    }
    
    private func appendToHistoryList(userText: String, responseText: String) {
        
        let conversation = ["conversationId": "null", "prompt": userText, "response": responseText, "gameCategory": global_gameId]
        
        if tokenManager.historyList.isEmpty {
            
            APIManager().createGptConversation(params: conversation) { result in
                
                switch result {
                case .success(let apiResponse):
                    
                   print(apiResponse)


                case .failure(let error):
                    print(error)
                }
                
                
            }
            
        } else {
            
            APIManager().updateGptConversation(params: conversation) { result in
                
                switch result {
                case .success(let apiResponse):
                    
                   print(apiResponse)


                case .failure(let error):
                    print(error)
                }
                
                
            }
            
        }
        
        tokenManager.appendMessageToHistory(userText: userText, responseText: responseText)
        
    
    }
    

    func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        var urlRequest = self.urlRequest
    
        if global_gameName != "SB Chatbot" {
            urlRequest.httpBody = try jsonBody(text: "Focus on \(global_gameName) game topic" + text)
        } else {
            urlRequest.httpBody = try jsonBody(text: text)
        }
        
        let (result, response) = try await urlSession.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "Invalid response"
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var errorText = ""
            for try await line in result.lines {
                errorText += line
            }
            
            if let data = errorText.data(using: .utf8), let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                errorText = "\n\(errorResponse.message)"
            }
            
            throw "Bad Response: \(httpResponse.statusCode), \(errorText)"
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                do {
                    var responseText = ""
                    for try await line in result.lines {
                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let response = try? self.jsonDecoder.decode(StreamCompletionResponse.self, from: data),
                           let text = response.choices.first?.delta.content {
                            responseText += text
                            continuation.yield(text)
                        }
                    }
                    
                    self.appendToHistoryList(userText: text, responseText: responseText)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    func sendMessage(_ text: String) async throws -> String {
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text, stream: false)
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "Invalid response"
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var error = "Bad Response: \(httpResponse.statusCode)"
            if let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                error.append("\n\(errorResponse.message)")
            }
            throw error
        }
        
        do {
            let completionResponse = try self.jsonDecoder.decode(CompletionResponse.self, from: data)
            let responseText = completionResponse.choices.first?.message.content ?? ""
            self.appendToHistoryList(userText: text, responseText: responseText)
            return responseText
        } catch {
            throw error
        }
    }
    
    func deleteHistoryList() {
        tokenManager.clearHistory()
        
        APIManager().clearGptConversation(gameId: global_gameId) { result in
            
            switch result {
            case .success(let apiResponse):
                
               print(apiResponse)


            case .failure(let error):
                print(error)
            }
            
            
        }
        
    }
    
    func setHistoryList(messages: [Message]) {
        tokenManager.setHistory(messages: messages)
    }
    
}

extension String: CustomNSError {
    
    public var errorUserInfo: [String : Any] {
        [
            NSLocalizedDescriptionKey: self
        ]
    }
}
