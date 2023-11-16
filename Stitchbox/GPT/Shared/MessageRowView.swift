//
//  MessageRowView.swift
//  XCAChatGPT
//
//  Created by Khoi Nguyen on 02/02/23.
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
            
            let sendImage = _AppCoreData.userDataSource.value?.gptAvatarURL
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
                    .font(.roboto(.Regular, size: 15)) // Set Roboto font here

                
            case .rawText(let text):
                if !text.isEmpty {
                    #if os(tvOS)
                    responseTextView(text: text)
                        .font(.roboto(.Regular, size: 15)) // Set Roboto font here
                    #else
                    Text(text)
                        .multilineTextAlignment(.leading)
                        .font(.roboto(.Regular, size: 15)) // Set Roboto font here
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
                    .font(.roboto(.Regular, size: 14)) // Set Roboto font here

                
               
                
                Button("Regenerate response") {
                    retryCallback(message)
                }
                .foregroundColor(.black)
                .padding(.top)
                .font(.roboto(.Regular, size: 14)) // Set Roboto font here

            
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
        .foregroundColor(isUser ? .white : .black)
        .padding()
        .background(isUser ? Color(red: (53.0/255.0), green: (46.0/255.0), blue: (113.0/255.0)): .normalButtonBackground)
        .cornerRadius(16)
        .font(.roboto(.Regular, size: 14)) // Set Roboto font here
        
        
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
                        .font(.roboto(.Regular, size: 15)) // Replace here
                        
                    #else
                    Text(parsed.attributedString)
                        #if os(iOS) || os(macOS)
                        .textSelection(.enabled)
                        .font(.roboto(.Regular, size: 15)) // Replace here
                        #endif
                    #endif
                } else {
                    Text(parsed.attributedString)
                        #if os(iOS) || os(macOS)
                        .textSelection(.enabled)
                        .font(.roboto(.Regular, size: 15)) // Replace here
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
                .font(.roboto(.Regular, size: 15)) // Replace here
                    
        }
    }
    #endif
    
}


