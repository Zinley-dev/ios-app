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
        
        while countTokens(messages: historyList) > maxTokenCount {
            if historyList.first?.role == "user" {
                historyList.removeFirst() // Remove user message
            }
            historyList.removeFirst() // Remove assistant message
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
            if historyList.first?.role == "user" {
                historyList.removeFirst() // Remove user message
            }
            historyList.removeFirst() // Remove assistant message
        }
    }
}

