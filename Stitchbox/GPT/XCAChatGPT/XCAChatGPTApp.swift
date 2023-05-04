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
}

struct ChatBotView: View {
    @StateObject var vm = ViewModel(api: ChatGPTAPI(apiKey: "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"))
    @ObservedObject var toolbarActions: ToolbarActions

    var body: some View {
        ContentView(vm: vm)
            .onAppear {
                toolbarActions.clearAction = {
                    vm.clearMessages()
                }
            }
            .onChange(of: vm.isInteractingWithChatGPT) { newValue in
                toolbarActions.isClearActionDisabled = newValue
            }
    }
}






