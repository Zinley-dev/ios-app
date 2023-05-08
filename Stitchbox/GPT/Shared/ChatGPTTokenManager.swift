//
//  ChatGPTTokenManager.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/7/23.
//

import Foundation
import GPTEncoder

class ChatGPTTokenManager {
    
    private let tokenizer: GPTEncoder
    private(set) var historyList: [Message]
    private var maxTokenCount: Int = 4096
    
    init(tokenizer: GPTEncoder) {
 
        self.tokenizer = tokenizer
        self.historyList = []
         
    }
    
    private func countTokens(messages: [Message]) -> Int {
        return messages.reduce(0) { $0 + tokenizer.encode(text: $1.content).count }
    }
    
    func appendMessageToHistory(userText: String, responseText: String) {
        
        if global_gpt == "gpt-4" {
            self.maxTokenCount = 8192
        } else {
            self.maxTokenCount = 4096
        }
        
        let userMessage = Message(role: "user", content: userText)
        let responseMessage = Message(role: "assistant", content: responseText)
                
        historyList.append(userMessage)
        historyList.append(responseMessage)
                
        // Remove messages until the token count is under the maximum limit
        while countTokens(messages: historyList) > maxTokenCount {
            if let firstMessage = historyList.first {
                // Remove only the first user message and its corresponding assistant message
                if firstMessage.role == "user" {
                    historyList.removeFirst(2)
                } else {
                    // If the first message is an assistant message, remove it
                    historyList.removeFirst()
                }
            }
        }
    }
    
    func clearHistory() {
        historyList.removeAll()
    }
    
    func setHistory(messages: [Message]) {
        
        if global_gpt == "gpt-4" {
            self.maxTokenCount = 8192
        } else {
            self.maxTokenCount = 4096
        }
        
        historyList = messages
        while countTokens(messages: historyList) > maxTokenCount {
                    if let firstMessage = historyList.first {
                        // Remove only the first user message and its corresponding assistant message
                        if firstMessage.role == "user" {
                            historyList.removeFirst(2)
                        } else {
                            // If the first message is an assistant message, remove it
                            historyList.removeFirst()
                        }
                    }
                }
    }
}

