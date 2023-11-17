//
//  MessageRow.swift
//  XCAChatGPT
//
//  Created by Khoi Nguyen on 02/02/23.
//

import SwiftUI

// MARK: - AttributedOutput Struct
// Represents an output that includes a string and an array of parser results.
struct AttributedOutput {
    let string: String // The original string.
    let results: [ParserResult] // Parsing results, which could include code blocks or other attributed text.
}

// MARK: - MessageRowType Enum
// Represents different types of message content.
enum MessageRowType {
    case attributed(AttributedOutput) // For attributed text with parsing results.
    case rawText(String) // For plain text messages.

    // Returns the text representation of the message, regardless of its type.
    var text: String {
        switch self {
        case .attributed(let attributedOutput):
            return attributedOutput.string
        case .rawText(let string):
            return string
        }
    }
}

// MARK: - MessageRow Struct
// Represents a row in a messaging interface, such as a chatbot conversation.
struct MessageRow: Identifiable {
    let id = UUID() // Unique identifier for SwiftUI lists.

    var isInteractingWithChatGPT: Bool // Flag indicating ongoing interaction with ChatGPT.
    
    let sendImage: String? // Optional image for the sent message.
    let send: MessageRowType? // The content of the sent message.
    var sendText: String? { // Text representation of the sent message.
        send?.text
    }
    
    let responseImage: String // Image associated with the response.
    var response: MessageRowType? // The content of the response message.
    var responseText: String? { // Text representation of the response message.
        response?.text
    }
    
    var responseError: String? // Optional error message related to the response.
}


