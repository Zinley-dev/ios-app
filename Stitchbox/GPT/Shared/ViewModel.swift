//
//  ViewModel.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 02/02/23.
//

import Foundation
import SwiftUI
import AVKit

class ViewModel: ObservableObject {
    
    @Published var isInteractingWithChatGPT = false
    @Published var messages: [MessageRow] = []
    @Published var history: [Message] = []
    @Published var inputMessage: String = ""
    
    #if !os(watchOS)
    private var synthesizer: AVSpeechSynthesizer?
    #endif
    
    private let api: ChatGPTAPI
    
    init(api: ChatGPTAPI, enableSpeech: Bool = false) {
        self.api = api
        #if !os(watchOS)
        if enableSpeech {
            synthesizer = .init()
        }
        #endif

    }

    
    @MainActor
    func sendTapped() async {
        let text = inputMessage
        inputMessage = ""
        #if os(iOS)
        await sendAttributed(text: text)
        #else
        await send(text: text)
        #endif
    }
    
    @MainActor
    func clearMessages() {
        stopSpeaking()
        api.deleteHistoryList()
        withAnimation { [weak self] in
            self?.messages = []
            
            if global_gameName == "SB Chatbot" {
                let welcomeMessage = MessageRow(
                    isInteractingWithChatGPT: false,
                    sendImage: nil,
                    send: nil,
                    responseImage: "openai",
                    response: .rawText("Welcome to SB-ChatBot! How can I help you today?")
                )
                self?.messages.append(welcomeMessage)
            } else {
                let welcomeMessage = MessageRow(
                    isInteractingWithChatGPT: false,
                    sendImage: nil,
                    send: nil,
                    responseImage: "openai",
                    response: .rawText("Welcome to SB-ChatBot for \(global_gameName)! How can I help you today?")
                )
                self?.messages.append(welcomeMessage)
            }
            
        }
    }
    
    
    @MainActor
    func retry(message: MessageRow) async {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else {
            return
        }
        self.messages.remove(at: index)
        #if os(iOS)
        await sendAttributed(text: message.sendText ?? "")
        #else
        await send(text: message.sendText)
        #endif
    }
    
    #if os(iOS)
    @MainActor
    private func sendAttributed(text: String) async {
        isInteractingWithChatGPT = true
        
        let parsingTask = ResponseParsingTask()
        let attributedSend = await parsingTask.parse(text: text)
        
        var streamText = ""
        var messageRow = MessageRow(
            isInteractingWithChatGPT: true,
            sendImage: "profile",
            send: .attributed(attributedSend),
            responseImage: "openai",
            responseError: nil)
        
        self.messages.append(messageRow)
        
        let parserThresholdTextCount = 64
        var currentTextCount = 0
        var currentOutput: AttributedOutput?
        
        do {
            let stream = try await api.sendMessageStream(text: text)
            for try await text in stream {
                streamText += text
                currentTextCount += text.count
                
                if currentTextCount >= parserThresholdTextCount || text.contains("```") {
                    currentOutput = await parsingTask.parse(text: streamText)
                    currentTextCount = 0
                }

                if let currentOutput = currentOutput, !currentOutput.results.isEmpty {
                    let suffixText = streamText.trimmingPrefix(currentOutput.string)
                    var results = currentOutput.results
                    let lastResult = results[results.count - 1]
                    var lastAttrString = lastResult.attributedString
                    if lastResult.isCodeBlock {
                        lastAttrString.append(AttributedString(String(suffixText), attributes: .init([.font: UIFont.systemFont(ofSize: 12).apply(newTraits: .traitMonoSpace), .foregroundColor: UIColor.white])))
                    } else {
                        lastAttrString.append(AttributedString(String(suffixText)))
                    }
                    results[results.count - 1] = ParserResult(attributedString: lastAttrString, isCodeBlock: lastResult.isCodeBlock, codeBlockLanguage: lastResult.codeBlockLanguage)
                    messageRow.response = .attributed(.init(string: streamText, results: results))
                } else {
                    messageRow.response = .attributed(.init(string: streamText, results: [
                        ParserResult(attributedString: AttributedString(stringLiteral: streamText), isCodeBlock: false, codeBlockLanguage: nil)
                    ]))
                }

                self.messages[self.messages.count - 1] = messageRow
            }
        } catch {
            messageRow.responseError = error.localizedDescription
            messageRow.response = .rawText(streamText)
        }
        
        if let currentString = currentOutput?.string, currentString != streamText {
            let output = await parsingTask.parse(text: streamText)
            messageRow.response = .attributed(output)
        }
        
        messageRow.isInteractingWithChatGPT = false
        self.messages[self.messages.count - 1] = messageRow
        isInteractingWithChatGPT = false
        speakLastResponse()
    }

    #endif
    
    @MainActor
    private func send(text: String) async {
        isInteractingWithChatGPT = true
        var streamText = ""
        var messageRow = MessageRow(
            isInteractingWithChatGPT: true,
            sendImage: "profile",
            send: .rawText(text),
            responseImage: "openai",
            response: .rawText(streamText),
            responseError: nil)
        
        self.messages.append(messageRow)
        
        do {
            let stream = try await api.sendMessageStream(text: text)
            for try await text in stream {
                streamText += text
                messageRow.response = .rawText(streamText.trimmingCharacters(in: .whitespacesAndNewlines))
                self.messages[self.messages.count - 1] = messageRow
            }
        } catch {
            messageRow.responseError = error.localizedDescription
        }
        
        messageRow.isInteractingWithChatGPT = false
        self.messages[self.messages.count - 1] = messageRow
        isInteractingWithChatGPT = false
        speakLastResponse()
        
    }
    
    func speakLastResponse() {
        #if !os(watchOS)
        guard let synthesizer, let responseText = self.messages.last?.responseText, !responseText.isEmpty else {
            return
        }
        stopSpeaking()
        let utterance = AVSpeechUtterance(string: responseText)
        utterance.voice = .init(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        synthesizer.speak(utterance )
        #endif
    }
    
    func stopSpeaking() {
        #if !os(watchOS)
        synthesizer?.stopSpeaking(at: .immediate)
        #endif
    }
    
    func setConversationHistory(messages: [Message]) {
        api.setHistoryList(messages: messages)
    }

    
    func getConversationHistory(completion: @escaping () -> Void) {
        
        if global_gameName == "SB Chatbot" {
            
            self.processFinalPreConversation(completion: completion)
            
        } else {
            
            APIManager.shared.getGamePatch(gameId: global_gameId) { result in
                switch result {
                case .success(let apiResponse):
                    
                    guard let data = apiResponse.body?["data"] as? [String: Any],
                          let conversationContent = data["conversationContent"] as? String else {
                        
                        DispatchQueue.main.async {
                            self.processFinalPreConversation(completion: completion)
                        }
                  
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.processFinalPreConversationWithMeta(conversationContent: conversationContent,completion: completion)
                    }

                  
                  
                case .failure(let error):
                    print(error)
                    
                    
                    DispatchQueue.main.async {
                        self.processFinalPreConversation(completion: completion)
                    }
                   
                    
                }
            }
            
            
        }
        
    
    }
    
    func processFinalPreConversation(completion: @escaping () -> Void) {
        
        
        APIManager.shared.getGptConversation(gameId: global_gameId) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                if let body = apiResponse.body,
                    let data = body["data"] as? [String: Any],
                    let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []),
                    let conversationHistory = try? JSONDecoder().decode(ConversationData.self, from: jsonData) {

                    for (prompt, response) in zip(conversationHistory.prompts, conversationHistory.responses) {
                        Task {
                            let userAttributedText = await ResponseParsingTask().parse(text: self.removeFocusSentence(prompt))
                            let assistantAttributedText = await ResponseParsingTask().parse(text: response)

                            let userMessage = MessageRow(
                                isInteractingWithChatGPT: false,
                                sendImage: "profile",
                                send: .attributed(userAttributedText),
                                responseImage: "openai",
                                response: nil
                            )
                            let assistantMessage = MessageRow(
                                isInteractingWithChatGPT: false,
                                sendImage: nil,
                                send: nil,
                                responseImage: "openai",
                                response: .attributed(assistantAttributedText)
                            )

                            let userHistory = Message(role: "user", content: prompt)
                            let assistantHistory = Message(role: "assistant", content: response)
                            
                            let guideUserHistory = Message(role: "user", content: "Prioritize truth, relevance, and brevity. Ensure logical layout. Understand context.")
                            let guideAssistantHistory = Message(role: "assistant", content: "Understood. I'll prioritize truth, relevance, brevity, logical layout, and context understanding.")


                            DispatchQueue.main.async {
                                self.messages.append(userMessage)
                                self.messages.append(assistantMessage)
                                self.history.append(userHistory)
                                self.history.append(assistantHistory)
                                self.history.append(guideUserHistory)
                                self.history.append(guideAssistantHistory)
                                self.setConversationHistory(messages: self.history)
                                completion()
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.displayWelcomeMessage(completion: completion)
                    }
                }

            case .failure(let error):
                print(error)

                DispatchQueue.main.async {
                    self.displayWelcomeMessage(completion: completion)
                }

            }
        }
        
        
    }

    
    func processFinalPreConversationWithMeta(conversationContent: String, completion: @escaping () -> Void) {
        
        
        APIManager.shared.getGptConversation(gameId: global_gameId) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                if let body = apiResponse.body,
                    let data = body["data"] as? [String: Any],
                    let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []),
                    let conversationHistory = try? JSONDecoder().decode(ConversationData.self, from: jsonData) {

                    for (prompt, response) in zip(conversationHistory.prompts, conversationHistory.responses) {
                        Task {
                            let userAttributedText = await ResponseParsingTask().parse(text: self.removeFocusSentence(prompt))
                            let assistantAttributedText = await ResponseParsingTask().parse(text: response)

                            let userMessage = MessageRow(
                                isInteractingWithChatGPT: false,
                                sendImage: "profile",
                                send: .attributed(userAttributedText),
                                responseImage: "openai",
                                response: nil
                            )
                            let assistantMessage = MessageRow(
                                isInteractingWithChatGPT: false,
                                sendImage: nil,
                                send: nil,
                                responseImage: "openai",
                                response: .attributed(assistantAttributedText)
                            )

                            let userHistory = Message(role: "user", content: prompt)
                            let assistantHistory = Message(role: "assistant", content: response)
                            
                            let guideUserHistory = Message(role: "user", content: "Prioritize truth, relevance, brevity, logical layout, and context. Follow this meta: \(conversationContent)")
                            let guideAssistantHistory = Message(role: "assistant", content: "Understood. I'll prioritize truth, relevance, brevity, logical layout, context understanding, and follow the provided meta.")



                            DispatchQueue.main.async {
                                self.messages.append(userMessage)
                                self.messages.append(assistantMessage)
                                self.history.append(userHistory)
                                self.history.append(assistantHistory)
                                self.history.append(guideUserHistory)
                                self.history.append(guideAssistantHistory)
                                self.setConversationHistory(messages: self.history)
                                completion()
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.displayWelcomeMessage(completion: completion)
                    }
                }

            case .failure(let error):
                print(error)

                DispatchQueue.main.async {
                    self.displayWelcomeMessage(completion: completion)
                }

            }
        }
        
        
    }

    
    func displayWelcomeMessage(completion: @escaping () -> Void)  {
        let welcomeText = global_gameName == "SB Chatbot" ? "Welcome to SB-ChatBot! How can I help you today?" : "Welcome to SB-ChatBot for \(global_gameName)! How can I help you today?"

        let welcomeMessage = MessageRow(
            isInteractingWithChatGPT: false,
            sendImage: nil,
            send: nil,
            responseImage: "openai",
            response: .rawText(welcomeText)
        )
        self.messages.append(welcomeMessage)
        
        let userHistory = Message(role: "user", content: "Please Prioritize accurate and relevant information, Ensure logical order and layout, Keep responses short, concise, and clear, Understand game context and tailor responses accordingly.")
        let assistantHistory = Message(role: "assistant", content: "Yes I will repsond based on prioritize accurate and relevant information, Ensure logical order and layout, Keep responses short, concise, and clear, Understand game context and tailor responses accordingly.")
        
        self.history.append(userHistory)
        self.history.append(assistantHistory)
        self.setConversationHistory(messages: self.history)
        
        completion()
    }

    func removeFocusSentence(_ input: String) -> String {
        
        if global_gameName == "SB Chatbot" {
            return input
        } else {
            
            let components = input.components(separatedBy: ".")
            if !components.isEmpty {
                let firstSentence = components.first!.trimmingCharacters(in: .whitespacesAndNewlines)
                let remainingText = input.replacingOccurrences(of: firstSentence + ".", with: "")
                return remainingText.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                return input.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
        }
        
        
    }

  
}

struct ConversationHistory: Codable {
    let data: ConversationData
}

struct ConversationData: Codable {
    let prompts: [String]
    let responses: [String]
}

extension String {
    func trimmingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}


