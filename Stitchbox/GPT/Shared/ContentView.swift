//
//  ContentView.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI
import AVKit

struct ContentView: View {
        
    //@Environment(\.colorScheme) var colorScheme
    @ObservedObject var vm: ViewModel
    @FocusState var isTextFieldFocused: Bool
    @State private var scrollOffset: CGFloat = .zero
    @State private var contentSize: CGSize = .zero

    var body: some View {
        chatListView
           
    }
    
    var chatListView: some View {
            ScrollViewReader { proxy in
                VStack(spacing: 0) {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(vm.messages) { message in
                                MessageRowView(message: message) { message in
                                    Task { @MainActor in
                                        await vm.retry(message: message)
                                    }
                                }
                            }
                        }
                        .background(GeometryReader {
                            Color.clear.preference(key: ViewOffsetKey.self,
                                                   value: -$0.frame(in: .named("scrollView")).origin.y)
                        })
                        .background(GeometryReader {
                            Color.clear.preference(key: ContentSizeKey.self, value: $0.size)
                        })
                        .onTapGesture {
                            isTextFieldFocused = false
                        }
                    }
                    .coordinateSpace(name: "scrollView")
                    .onPreferenceChange(ViewOffsetKey.self) { scrollOffset in
                        self.scrollOffset = scrollOffset
                    }
                    .onPreferenceChange(ContentSizeKey.self) { contentSize in
                        self.contentSize = contentSize
                    }
                #if os(iOS) || os(macOS)
                Divider()
                bottomView(image: _AppCoreData.userDataSource.value?.avatarURL ?? "defaultuser", proxy: proxy)
                Spacer()
                #endif
            }
            .onChange(of: vm.messages.last?.responseText) { _ in
                if isUserNearBottom() {
                    scrollToBottom(proxy: proxy)
                }
            }
            // Set the background color to a specific color
            .background(Color(red: 58/255, green: 60/255, blue: 64/255, opacity: 1.0))
        }
    }
    
    private func isUserNearBottom() -> Bool {
        let scrollableContentHeight = contentSize.height - UIScreen.main.bounds.height
        return scrollableContentHeight - abs(scrollOffset) < 100 // Change this value to adjust the sensitivity
    }


    func bottomView(image: String, proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .top, spacing: 8) {
            if image.hasPrefix("http"), let url = URL(string: image) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                        .cornerRadius(15)
                } placeholder: {
                    ProgressView()
                }

            } else {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .cornerRadius(15)
            }
            
            TextField("Ask us anything!", text: $vm.inputMessage, axis: .vertical)
                #if os(iOS) || os(macOS)
                .textFieldStyle(.plain)
                .scrollContentBackground(.hidden) // <- Hide it
                .background(.clear) // To see this
                .foregroundColor(.white)
                #endif
                .focused($isTextFieldFocused)
                .disabled(vm.isInteractingWithChatGPT)
            
            if vm.isInteractingWithChatGPT {
                DotLoadingView().frame(width: 40, height: 30)
            } else {
                Button {
                    Task { @MainActor in
                        isTextFieldFocused = false
                        scrollToBottom(proxy: proxy)
                        await vm.sendTapped()
                    }
                } label: {
                    Image.init("send2")
                  
                }
                #if os(macOS)
                .buttonStyle(.borderless)
                .keyboardShortcut(.defaultAction)
                .foregroundColor(.white) // Set the color of the button icon to white
                .background(Color.clear) // Set the background color of the button to black
                #endif
                .disabled(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .background(Color.clear) // Set the background color of the entire bottom view to black
    }

    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = vm.messages.last?.id else { return }
        proxy.scrollTo(id, anchor: .bottomTrailing)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView(vm: ViewModel(api: ChatGPTAPI(apiKey: "PROVIDE_API_KEY")))
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct ContentSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = CGSize(width: max(value.width, nextValue().width), height: max(value.height, nextValue().height))
    }
}
