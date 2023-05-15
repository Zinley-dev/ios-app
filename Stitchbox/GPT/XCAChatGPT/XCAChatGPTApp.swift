//
//  XCAChatGPTApp.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI

class ToolbarActions: ObservableObject {
    @Published var clearAction: (() -> Void)?
    @Published var isClearActionDisabled: Bool = false
    @Published var getConversationHistory: (() -> Void)?
   
}

struct ChatBotView: View {
    @StateObject var vm = ViewModel(api: ChatGPTAPI(apiKey: "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"))
    @ObservedObject var toolbarActions: ToolbarActions
    @State private var scrollToLastMessage: Bool = false
    @State private var didLoadHistory: Bool = false
    
    var body: some View {
        ContentView(vm: vm, scrollToLastMessage: $scrollToLastMessage)
            .onAppear {
                if !didLoadHistory {
                    vm.getConversationHistory {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            withAnimation {
                                scrollToLastMessage = true
                            }
                        }
                    }
                    didLoadHistory = true
                }
                toolbarActions.clearAction = {
                    vm.clearMessages()
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
