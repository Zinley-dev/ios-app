//
//  MessageRowView.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 02/02/23.
//

import SwiftUI
#if os(iOS)
import Markdown
#endif
import SendBirdUIKit

struct MessageRowView: View {
    
    //@Environment(\.colorScheme) private var colorScheme
    let message: MessageRow
    let retryCallback: (MessageRow) -> Void
    
    var imageSize: CGSize {
        #if os(iOS) || os(macOS)
        CGSize(width: 40, height: 40)
        #elseif os(watchOS)
        CGSize(width: 20, height: 20)
        #else
        CGSize(width: 80, height: 80)
        #endif
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            let sendImage = _AppCoreData.userDataSource.value?.avatarURL
            let responseImage = "defaultuser"
            
            
            if let send = message.send {
                messageRow(rowType: send, image: sendImage ?? "defaultuser", bgColor: Color.clear)
            }

            
            if let response = message.response {
                messageRow(rowType: response, image: responseImage, bgColor: Color.clear, responseError: message.responseError, isUser: false,showDotLoading: message.isInteractingWithChatGPT)
            }
        }
        .background(Color.clear) // set the background color to clear
    }
    
    func messageRow(rowType: MessageRowType, image: String, bgColor: Color, responseError: String? = nil, isUser: Bool = true,showDotLoading: Bool = false) -> some View {
        #if os(watchOS)
        VStack(alignment: .leading, spacing: 0) {
            messageRowContent(rowType: rowType, image: image, responseError: responseError, showDotLoading: showDotLoading)
        }
        
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bgColor)
        #else
        HStack(alignment: .top, spacing: 8) {
            messageRowContent(rowType: rowType, image: image, responseError: responseError, isUser: isUser,showDotLoading: showDotLoading)
        }
        #if os(tvOS)
        .padding(32)
        #else
        .padding(16)
        #endif
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bgColor)
        #endif
    }
    @ViewBuilder
    func imageBuilder(image: String) -> some View {
        if image.hasPrefix("http"), let url = URL(string: image) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageSize.width, height: imageSize.height)
                    .cornerRadius(imageSize.width/2)
            } placeholder: {
                ProgressView()
            }
        } else {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: imageSize.width, height: imageSize.height)
                .cornerRadius(imageSize.width/2)
        }
    }

    
    @ViewBuilder
    func messageRowContent(rowType: MessageRowType, image: String, responseError: String? = nil, isUser: Bool = true,showDotLoading: Bool = false) -> some View {
        if !isUser {imageBuilder(image: image)}
        if isUser {Spacer()}
        VStack(alignment: .leading) {
            switch rowType {
            case .attributed(let attributedOutput):
                attributedView(results: attributedOutput.results)
                    .font(.system(size: 15)) // And here

                
            case .rawText(let text):
                if !text.isEmpty {
                    #if os(tvOS)
                    responseTextView(text: text)
                        .font(.system(size: 15)) // And here
                    #else
                    Text(text)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15)) // And here
                        #if os(iOS) || os(macOS)
                        .textSelection(.enabled)
                        #endif
                    #endif
                }
            }
            if let error = responseError {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 14)) // Set font here
                
                Button("Regenerate response") {
                    retryCallback(message)
                }
                .foregroundColor(.white)
                .padding(.top)
                .font(.system(size: 14)) // Set font here
            
            }
            
            if showDotLoading {
                #if os(tvOS)
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding()
                #else
                DotLoadingView()
                    .frame(width: 40, height: 30)
                #endif
                
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(isUser ? Color(red: (53.0/255.0), green: (46.0/255.0), blue: (113.0/255.0)): Color(red: 51/255, green: 51/255, blue: 51/255))
        .cornerRadius(16)
        .font(.system(size: 14)) // Set font here
        
        
        //SBUTheme.componentTheme
        if !isUser {Spacer()}
        if isUser {imageBuilder(image: image)}
    }
    
    func attributedView(results: [ParserResult]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(results) { parsed in
                if parsed.isCodeBlock {
                    #if os(iOS)
                    CodeBlockView(parserResult: parsed)
                        .padding(.bottom, 36)
                        .font(.system(size: 15)) // And here
                        
                    #else
                    Text(parsed.attributedString)
                        #if os(iOS) || os(macOS)
                        .textSelection(.enabled)
                        .font(.system(size: 15)) // And here
                        #endif
                    #endif
                } else {
                    Text(parsed.attributedString)
                        #if os(iOS) || os(macOS)
                        .textSelection(.enabled)
                        .font(.system(size: 15)) // And here
                        #endif
                }
            }
        }
    }
    
    #if os(tvOS)
    private func rowsFor(text: String) -> [String] {
        var rows = [String]()
        let maxLinesPerRow = 8
        var currentRowText = ""
        var currentLineSum = 0
        
        for char in text {
            currentRowText += String(char)
            if char == "\n" {
                currentLineSum += 1
            }
            
            if currentLineSum >= maxLinesPerRow {
                rows.append(currentRowText)
                currentLineSum = 0
                currentRowText = ""
            }
        }

        rows.append(currentRowText)
        return rows
    }
    
    
    func responseTextView(text: String) -> some View {
        ForEach(rowsFor(text: text), id: \.self) { text in
            Text(text)
                .focusable()
                .multilineTextAlignment(.leading)
                .font(.system(size: 15)) // And here
                
        }
    }
    #endif
    
}

struct MessageRowView_Previews: PreviewProvider {
    
    static let message = MessageRow(
        isInteractingWithChatGPT: true, sendImage: "profile",
        send: .rawText("What is SwiftUI?"),
        responseImage: "openai",
        response: responseMessageRowType)
    
    static let message2 = MessageRow(
        isInteractingWithChatGPT: false, sendImage: "profile",
        send: .rawText("What is SwiftUI?"),
        responseImage: "openai",
        response: .rawText(""),
        responseError: "ChatGPT is currently not available")
        
    static var previews: some View {
        NavigationStack {
            ScrollView {
                MessageRowView(message: message, retryCallback: { messageRow in
                    
                })
                    
                MessageRowView(message: message2, retryCallback: { messageRow in
                    
                })
                  
            }
            .previewLayout(.sizeThatFits)
        }
    }
    
    static var responseMessageRowType: MessageRowType {
        #if os(iOS)
        let document = Document(parsing: rawString)
        var parser = MarkdownAttributedStringParser()
        let results = parser.parserResults(from: document)
        return MessageRowType.attributed(.init(string: rawString, results: results))
        #else
        MessageRowType.rawText(rawString)
        #endif
    }
    
    static var rawString: String {
        #if os(iOS)
        """
        ## Supported Platforms

        - iOS/tvOS 15 and above
        - macOS 12 and above
        - watchOS 8 and above
        - Linux

        ## Installation

        ### Swift Package Manager
        - File > Swift Packages > Add Package Dependency
        - Add https://github.com/alfianlosari/ChatGPTSwift.git

        ### Cocoapods
        ```ruby
        platform :ios, '15.0'
        use_frameworks!

        target 'MyApp' do
          pod 'ChatGPTSwift', '~> 1.3.1'
        end
        ```

        ## Requirement

        Register for API key from [OpenAI](https://openai.com/api). Initialize with api key

        ```swift
        let api = ChatGPTAPI(apiKey: "API_KEY")
        ```

        ## Usage

        There are 2 APIs: stream and normal

        ### Stream

        The server will stream chunks of data until complete, the method `AsyncThrowingStream` which you can loop using For-Loop like so:

        ```swift
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

        ### Normal
        A normal HTTP request and response lifecycle. Server will send the complete text (it will take more time to response)

        ```swift
        Task {
            do {
                let response = try await api.sendMessage(text: "What is ChatGPT?")
                print(response)
            } catch {
                print(error.localizedDescription)
            }
        }
        ```
        """
        #else
        "SwiftUI is a user interface framework that allows developers to design and develop user interfaces for iOS, macOS, watchOS, and tvOS applications using Swift, a programming language developed by Apple Inc."
        #endif
    }
}


