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
    private var maxTokenCount: Int = 16000
    
    init(tokenizer: GPTEncoder) {
 
        self.tokenizer = tokenizer
        self.historyList = []
         
    }
    
    private func countTokens(messages: [Message]) -> Int {
        return messages.reduce(0) { $0 + tokenizer.encode(text: $1.content).count }
    }
    
    func appendMessageToHistory(userText: String, responseText: String) {
        
        if global_gpt == "gpt-4-0613" {
            self.maxTokenCount = 8192
        } else {
            self.maxTokenCount = 16000
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
        guard historyList.count > 2 else { return } // If there are only guide messages, no need to do anything.
        historyList = Array(historyList.prefix(2)) // Keep only the first two messages
    }

    
    func setHistory(messages: [Message]) {
        
        if global_gpt == "gpt-4-0613" {
            self.maxTokenCount = 8192
        } else {
            self.maxTokenCount = 16000
        }
        
        historyList = messages
        while countTokens(messages: historyList) > maxTokenCount {
            if historyList.count > 2 {
                // Remove the third message and its corresponding assistant message
                if historyList[2].role == "user" {
                    historyList.remove(at: 2)
                    if historyList.count > 3 { // Make sure there is another message to remove after this
                        historyList.remove(at: 2) // Now remove the corresponding assistant message
                    }
                } else {
                    // If the third message is an assistant message, remove it
                    historyList.remove(at: 2)
                }
            }
        }
    }

}

