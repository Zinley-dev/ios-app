//
//  ParserResult.swift
//  XCAChatGPT
//
//  Created by Khoi Nguyen on 19/04/23.
//

import Foundation

// MARK: - ParserResult Struct
// Represents the result of parsing text, potentially including code blocks.

struct ParserResult: Identifiable {
    
    // A unique identifier for each instance, useful in SwiftUI lists.
    let id = UUID()

    // The attributed string resulting from the parsing operation.
    let attributedString: AttributedString

    // A Boolean flag indicating whether this result represents a code block.
    let isCodeBlock: Bool

    // An optional string representing the programming language of the code block, if applicable.
    let codeBlockLanguage: String?
    
}


