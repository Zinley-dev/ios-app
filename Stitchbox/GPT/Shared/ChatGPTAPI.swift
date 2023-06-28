//
//  ChatGPTAPI.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import Foundation
import GPTEncoder


class ChatGPTAPI: @unchecked Sendable {
    
    private let tokenizer: GPTEncoder
    private let systemMessage: Message
    private let temperature: Double
    private let tokenManager: ChatGPTTokenManager
    private let apiKey: String
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
        self.tokenizer = GPTEncoder()
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
        
        
        
        let conversation = ["conversationId": "null", "prompt": userText, "response": responseText, "gameCategory": chatbot_id]
    
        if tokenManager.historyList.count <= 2 {
            
            APIManager.shared.createGptConversation(params: conversation) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let apiResponse):
                    
                   print(apiResponse)


                case .failure(let error):
                    print(error)
                }
                
                
            }
            
        } else {
            
            APIManager.shared.updateGptConversation(params: conversation) { [weak self] result in
                guard let self = self else { return }
                
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
    
    private func countTokens(messages: String) -> Int {
        return tokenizer.encode(text: messages).count
    }
    

    func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        
        var urlRequest = self.urlRequest

        let requestBodyText = text
        urlRequest.httpBody = try jsonBody(text: requestBodyText)
  
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

    
    func deleteHistoryList() {
        tokenManager.clearHistory()
        
        
        APIManager.shared.clearGptConversation(gameId: chatbot_id) { [weak self] result in
            guard let self = self else { return }
            
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
