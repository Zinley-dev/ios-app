//
//  ContentView.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI
import AVKit
import SendBirdUIKit

struct ContentView: View {
        
    //@Environment(\.colorScheme) var colorScheme
    @ObservedObject var vm: ViewModel
    @FocusState var isTextFieldFocused: Bool
    @State private var scrollOffset: CGFloat = .zero
    @State private var contentSize: CGSize = .zero
    @Binding var scrollToLastMessage: Bool
    
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
                bottomView(image: _AppCoreData.userDataSource.value?.gptAvatarURL ?? "defaultuser", proxy: proxy)
                Spacer()
            #endif
            }
            .onChange(of: vm.messages.last?.responseText) { _ in
                if isUserNearBottom() {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: scrollToLastMessage) { value in
                if value {
                    scrollToBottom(proxy: proxy)
                }
            }
            // Set the background color to a specific color
            .background(Color(red: 58/255, green: 60/255, blue: 64/255, opacity: 1.0))
        }
    }

    
    private func isUserNearBottom() -> Bool {
        let scrollableContentHeight = contentSize.height - UIScreen.main.bounds.height
        let threshold: CGFloat = 55
        return (scrollableContentHeight - abs(scrollOffset)) < threshold
    }

    func bottomView(image: String, proxy: ScrollViewProxy) -> some View {
        
        HStack(alignment: .center, spacing: 8) {
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
            

            
            TextField("", text: $vm.inputMessage, prompt: Text("Ask us anything!").foregroundColor(.gray), axis: .vertical)
                #if os(iOS) || os(macOS)
                .textFieldStyle(.plain)
                .preferredColorScheme(.dark)
                .background(.clear) // To see this
                .foregroundColor(.white)
                .accentColor(Color(red: 194.0 / 255.0, green: 169.0 / 255.0, blue: 250.0 / 255.0, opacity: 1.0)) // Set the color of the placeholder
                .font(.system(size: 15)) // And here
            
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
                        do {
                            
                            try await Task.sleep(nanoseconds: 350_000_000) // 550 million nanoseconds = 0.55 seconds
                            await vm.sendTapped()
                            
                        } catch {
                            
                            await vm.sendTapped()
                        }
                        
                    }
                } label: {
                    Image.init("send2")
                }
                #if os(macOS)
                .buttonStyle(.borderless)
                .keyboardShortcut(.defaultAction)
                .foregroundColor(.white)
                .background(Color.clear)
                #endif
                .disabled(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .background(Color.clear)
       
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = vm.messages.last?.id else { return }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7, blendDuration: 0)) {
            proxy.scrollTo(id, anchor: .bottomTrailing)
        }
    }


}

struct ContentView_Previews: PreviewProvider {
    @State static private var dummyScrollToLastMessage = false
    
    static var previews: some View {
        NavigationStack {
            ContentView(vm: ViewModel(api: ChatGPTAPI(apiKey: "PROVIDE_API_KEY")), scrollToLastMessage: $dummyScrollToLastMessage)
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

struct SuperTextField: View {

    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}
