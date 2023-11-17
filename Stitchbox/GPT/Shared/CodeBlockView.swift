//
//  CodeBlockView.swift
//  XCAChatGPT
//
//  Created by Khoi Nguyen on 19/04/23.
//

import SwiftUI
import Markdown

// Constants for the code block view.
enum HighlighterConstants {
    static let color = Color(red: 244/255, green: 244/255, blue: 244/255) // Light gray color
}

// MARK: - CodeBlockView
// A view for displaying a code block with syntax highlighting and copy functionality.
struct CodeBlockView: View {
    
    // The result of parsing the code block.
    let parserResult: ParserResult

    // State to track if the code block has been copied to the clipboard.
    @State var isCopied = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // Header view displaying the language of the code block.
            header
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white)
                .font(.system(size: 15)) // Replace with desired font
                .foregroundColor(.black)
            
            // Scrollable view containing the code block.
            ScrollView(.horizontal, showsIndicators: true) {
                Text(parserResult.attributedString)
                    .padding(.horizontal, 16)
                    .textSelection(.enabled)
                    .font(.system(size: 15, design: .monospaced)) // Replace with desired font
                    .foregroundColor(.black)
            }
        }
        .background(HighlighterConstants.color)
        .cornerRadius(8)
    }

    // Header view containing the language label and copy button.
    var header: some View {
        HStack {
            // Language label.
            if let codeBlockLanguage = parserResult.codeBlockLanguage {
                Text(codeBlockLanguage.capitalized)
                    .font(.headline.monospaced())
                    .foregroundColor(.black)
            }
            Spacer()
            // Copy button.
            button
        }
    }
    
    // Copy button view.
    @ViewBuilder
    var button: some View {
        if isCopied {
            // View showing "Copied" status.
            HStack {
                Text("Copied")
                    .foregroundColor(.black)
                    .font(.subheadline.monospaced().bold())
                Image(systemName: "checkmark.circle.fill")
                    .imageScale(.large)
                    .symbolRenderingMode(.multicolor)
            }
            .frame(alignment: .trailing)
        } else {
            // Button for copying the code.
            Button {
                // Copy the code to the clipboard.
                let string = NSAttributedString(parserResult.attributedString).string
                UIPasteboard.general.string = string
                withAnimation {
                    isCopied = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isCopied = false
                    }
                }
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .foregroundColor(.black)
        }
    }
}

// MARK: - CodeBlockView_Previews
// Preview provider for the CodeBlockView.
struct CodeBlockView_Previews: PreviewProvider {
    // Sample Markdown string containing a Swift code block.
    static var markdownString = """
    ```swift
    // Sample Swift code here.
    ```
    """
    
    // Sample ParserResult for the preview.
    static let parserResult: ParserResult = {
        let document = Document(parsing: markdownString)
        var parser = MarkdownAttributedStringParser()
        return parser.parserResults(from: document)[0]
    }()
    
    static var previews: some View {
        CodeBlockView(parserResult: parserResult)
    }
}

