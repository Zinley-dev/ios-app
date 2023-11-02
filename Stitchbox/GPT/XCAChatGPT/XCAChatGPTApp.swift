//
//  XCAChatGPTApp.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI

class ToolbarActions: ObservableObject {
    
    deinit {
        print("ToolbarActions is being deallocated")
        // cleanup code
    }
    
    
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
