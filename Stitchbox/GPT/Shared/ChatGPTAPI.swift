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
        
        let conversation = ["conversationId": "null", "prompt": userText, "response": responseText, "gameCategory": global_gameId]
    
        if tokenManager.historyList.count <= 2 {
            
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
        updateToken(tokens: countTokens(messages: userText + responseText))
        
    }
    
    func checkTokenLimit() {
        
        APIManager().getUsedToken { result in
            switch result {
            case .success(let apiResponse):
                
                if let data = apiResponse.body, let remainToken = data["remainToken"] as? Int {
                
                    if remainToken > 0 {
                        isTokenLimit = false
                    } else {
                        isTokenLimit = true
                    }
                    
                } else {
                    isTokenLimit = true
                }
              
            case .failure(let error):
                
                isTokenLimit = true
                print(error)
                
            }
        }
        
    }
    
    func updateToken(tokens: Int) {
        
        APIManager().updateUsedToken(usedToken: tokens) { result in
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
                self.checkTokenLimit()
              
            case .failure(let error):
                print(error)
                self.checkTokenLimit()
            }
        }
        
    }
    
    private func countTokens(messages: String) -> Int {
        return tokenizer.encode(text: messages).count
    }
    

    func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        
        if isPro {
            
            var urlRequest = self.urlRequest

            let requestBodyText = global_gameName != "SB Chatbot" ? "Focus strictly on the \(global_gameName) game topic. Disregard unrelated questions. Query: \(text)" : text
            urlRequest.httpBody = try jsonBody(text: requestBodyText)
            
            print(requestBodyText)

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
            
            
        } else {
            
            if isTokenLimit {
                
                var errorText = ""
                errorText = "\n\("Your token limit may be reached soon! To enjoy uninterrupted and limitless experiences, please consider upgrading to SB Pro today.")"
                
                throw "Bad Response: \(errorText)"
                
                
            } else {
                
                var urlRequest = self.urlRequest
            
                if global_gameName != "SB Chatbot" {
                    urlRequest.httpBody = try jsonBody(text: "Focus and answer only relates to \(global_gameName) game topic" + text)
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
