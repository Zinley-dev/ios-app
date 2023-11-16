//
//  ParserResult.swift
//  XCAChatGPT
//
//  Created by Khoi Nguyen on 19/04/23.
//

import Foundation

struct ParserResult: Identifiable {
    
    let id = UUID()
    let attributedString: AttributedString
    let isCodeBlock: Bool
    let codeBlockLanguage: String?
    
}

