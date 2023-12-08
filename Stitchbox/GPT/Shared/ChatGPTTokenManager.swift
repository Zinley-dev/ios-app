//
//  ChatGPTTokenManager.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/7/23.
//

import Foundation
import GPTEncoder

// MARK: - ChatGPTTokenManager Class
// Manages the tokenization and history of messages in a chat with GPT models.

class ChatGPTTokenManager {
    
    // Called when the instance is being deallocated.
    deinit {
        //print("ChatGPTTokenManager instance is being deallocated")
    }

    // The tokenizer used for encoding text into tokens.
    private let tokenizer: GPTEncoder
    // The list that holds the history of messages.
    private(set) var historyList: [Message]
    // The maximum token count allowed in the history.
    private var maxTokenCount: Int = 16384
    
    // Initializes with a given tokenizer.
    init(tokenizer: GPTEncoder) {
        self.tokenizer = tokenizer
        self.historyList = []
    }
    
    // Counts the total number of tokens in a list of messages.
    private func countTokens(messages: [Message]) -> Int {
        return messages.reduce(0) { $0 + tokenizer.encode(text: $1.content).count }
    }
    
    // Appends a user message and a response message to the history.
    func appendMessageToHistory(userText: String, responseText: String) {
        adjustMaxTokenCount() // Adjust the max token count based on the GPT model
        
        let userMessage = Message(role: "user", content: userText)
        let responseMessage = Message(role: "assistant", content: responseText)
                
        historyList.append(userMessage)
        historyList.append(responseMessage)
                
        // Remove messages until the token count is under the maximum limit.
        trimHistory()
    }
    
    // Clears the history, keeping only the initial guide messages if present.
    func clearHistory() {
        guard historyList.count > 2 else { return }
        historyList = Array(historyList.prefix(2))
    }
    
    // Sets the history to a given list of messages and ensures it's within token limits.
    func setHistory(messages: [Message]) {
        adjustMaxTokenCount()
        
        historyList = messages
        trimHistory()
    }

    // Adjusts the maximum token count based on the GPT model being used.
    private func adjustMaxTokenCount() {
        if global_gpt == "gpt-4-0613" {
            maxTokenCount = 8192
        } else {
            maxTokenCount = 16384
        }
    }

    // Trims the history list to ensure it stays within the token limit.
    private func trimHistory() {
        while countTokens(messages: historyList) > maxTokenCount {
            if historyList.count > 2 {
                removeEarliestMessages()
            }
        }
    }

    // Removes the earliest messages in pairs (user and corresponding assistant message).
    private func removeEarliestMessages() {
        if historyList[2].role == "user" {
            historyList.remove(at: 2)
            if historyList.count > 3 {
                historyList.remove(at: 2)
            }
        } else {
            historyList.remove(at: 2)
        }
    }
}
