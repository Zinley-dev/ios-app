//
//  CodeBlockView.swift
//  XCAChatGPT
//
//  Created by Khoi Nguyen on 19/04/23.
//

import SwiftUI
import Markdown

enum HighlighterConstants {
    static let color = Color(red: 244/255, green: 244/255, blue: 244/255) // Light Gray
}

struct CodeBlockView: View {
    
    let parserResult: ParserResult
    @State var isCopied = false
    
    var body: some View {
        VStack(alignment: .leading) {
            header
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white)
                .font(.roboto(.Regular, size: 15)) // Replace here
                .foregroundColor(.black)
            
            ScrollView(.horizontal, showsIndicators: true) {
                Text(parserResult.attributedString)
                    .padding(.horizontal, 16)
                    .textSelection(.enabled)
                    .font(.roboto(.Regular, size: 15)) // Replace here
                    .foregroundColor(.black)
            }
        }
        .background(HighlighterConstants.color)
        .cornerRadius(8)
    }

    
    var header: some View {
        HStack {
            if let codeBlockLanguage = parserResult.codeBlockLanguage {
                Text(codeBlockLanguage.capitalized)
                    .font(.headline.monospaced())
                    .foregroundColor(.black)
            }
            Spacer()
            button
        }
    }
    
    @ViewBuilder
    var button: some View {
        if isCopied {
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
            Button {
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

struct CodeBlockView_Previews: PreviewProvider {
    
    static var markdownString = """
    ```swift
    let api = ChatGPTAPI(apiKey: "API_KEY")

    Task {
        do {
            let stream = try await api.sendMessageStream(text: "What is ChatGPT?")
            for try await line in stream {
                print(line)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    ```
    """
    
    static let parserResult: ParserResult = {
        let document = Document(parsing: markdownString)
        var parser = MarkdownAttributedStringParser()
        return parser.parserResults(from: document)[0]
    }()
    
    static var previews: some View {
        CodeBlockView(parserResult: parserResult)
    }
}

