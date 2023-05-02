//
//  XCAChatGPTApp.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI

struct ChatBotView: View {
    @StateObject var vm = ViewModel(api: ChatGPTAPI(apiKey: "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"))
    
    var body: some View {
        NavigationView {
            ContentView(vm: vm)
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            vm.clearMessages()
                        }) {
                            Text("Clear")
                                .foregroundColor(Color(red: (254.0/255.0), green: (138.0/255.0), blue: (92.0/255.0)))
                        }
                        .disabled(vm.isInteractingWithChatGPT)
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                }
        }
        
    }
}




