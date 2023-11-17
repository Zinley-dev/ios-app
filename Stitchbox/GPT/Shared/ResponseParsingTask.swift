//
//  ResponseParsingTask.swift
//  XCAChatGPT
//
//  Created by Khoi Nguyen on 19/04/23.
//

import Foundation
import Markdown

// MARK: - ResponseParsingTask Actor
// An actor that handles the parsing of Markdown text.

actor ResponseParsingTask {
    
    // Asynchronously parses the provided text into Markdown format.
    // - Parameter text: The string to be parsed.
    // - Returns: AttributedOutput containing the parsed results.
    func parse(text: String) async -> AttributedOutput {
        // Creating a Markdown document from the input text.
        let document = Document(parsing: text)

        // Initializing a Markdown parser.
        var markdownParser = MarkdownAttributedStringParser()

        // Parsing the document and retrieving the results.
        let results = markdownParser.parserResults(from: document)

        // Returning the attributed output, which includes the original string and parsed results.
        return AttributedOutput(string: text, results: results)
    }
}


