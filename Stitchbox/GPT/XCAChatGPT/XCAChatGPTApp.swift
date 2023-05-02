//
//  XCAChatGPTApp.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI

struct ChatBotView: View {
    @StateObject var vm = ViewModel(api: ChatGPTAPI(apiKey: "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"))
    @State var isShowingTokenizer = false
    
    var body: some View {
        NavigationView {
            ContentView(vm: vm)
                .toolbar {
                    ToolbarItem {
                        Button("Clear") {
                            vm.clearMessages()
                        }
                        .disabled(vm.isInteractingWithChatGPT)
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Tokenizer") {
                            self.isShowingTokenizer = true
                        }
                        .disabled(vm.isInteractingWithChatGPT)
                    }
                }
        }
        .fullScreenCover(isPresented: $isShowingTokenizer) {
            NavigationTokenView(isPresented: $isShowingTokenizer)
        }
    }
}




struct NavigationTokenView: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            TokenizerView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            isPresented = false
                        }
                    }
                }
        }
        .interactiveDismissDisabled()
    }
}



