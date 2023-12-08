//
//  XCAChatGPTApp.swift
//  XCAChatGPT
//
//  Created by Khoi Nguyen on 01/02/23.
//

import SwiftUI

// MARK: - ToolbarActions Class
// Observable object managing actions in the toolbar of the chat interface.
class ToolbarActions: ObservableObject {
    deinit {
        //print("ToolbarActions is being deallocated")
        // Place for cleanup code if needed.
    }

    @Published var clearAction: (() -> Void)? // Action to clear the chat.
    @Published var isClearActionDisabled: Bool = false // State to disable clear action.
    @Published var getConversationHistory: (() -> Void)? // Action to fetch conversation history.
}

// MARK: - ChatBotView Struct
// Main view for the chatbot interface.
struct ChatBotView: View {
    @StateObject var vm = ViewModel(api: ChatGPTAPI(apiKey: "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"))
    @ObservedObject var toolbarActions: ToolbarActions
    @State private var scrollToLastMessage: Bool = false
    @State private var didLoadHistory: Bool = false

    var body: some View {
        ContentView(vm: vm, scrollToLastMessage: $scrollToLastMessage)
            .onAppear {
                if !didLoadHistory {
                    // Fetch conversation history on first appearance.
                    vm.getConversationHistory {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            withAnimation {
                                scrollToLastMessage = true
                            }
                        }
                    }
                    didLoadHistory = true
                }

                // Assign clear messages action to toolbar.
                toolbarActions.clearAction = { [weak vm] in
                    vm?.clearMessages()
                }
            }
            .onChange(of: scrollToLastMessage) { newValue in
                if newValue {
                    scrollToLastMessage = false
                }
            }
            .onChange(of: vm.isInteractingWithChatGPT) { newValue in
                toolbarActions.isClearActionDisabled = newValue
            }
    }
}

// MARK: - ImageButton Struct
// Reusable button view with an image.
struct ImageButton: View {
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
    }
}
