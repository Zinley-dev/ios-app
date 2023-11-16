//
//  ContentView.swift
//  XCAChatGPT
//
//  Created by Khoi Nguyen on 02/02/23.
//


import SwiftUI
import AVKit
import SendBirdUIKit

struct ContentView: View {
    @ObservedObject var vm: ViewModel
    @FocusState var isTextFieldFocused: Bool
    @State private var scrollOffset: CGFloat = .zero
    @State private var contentSize: CGSize = .zero
    @Binding var scrollToLastMessage: Bool
    
    var body: some View {
        chatListView.background(Color.white)
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
                .background(Color.white)

                Divider()
                bottomView(image: _AppCoreData.userDataSource.value?.gptAvatarURL ?? "defaultuser", proxy: proxy)
                Spacer()
            }
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

            if #available(iOS 16.0, *) {
                TextField("", text: $vm.inputMessage, prompt: Text("Ask us anything!").foregroundColor(.black), axis: .vertical)
                    .textFieldStyle(.plain)
                    .preferredColorScheme(.light)
                    .background(.clear)
                    .foregroundColor(.black)
                    .accentColor(Color(red: 194.0 / 255.0, green: 169.0 / 255.0, blue: 250.0 / 255.0, opacity: 1.0))
                    .font(.roboto(.Regular, size: 15)) // Replace here
                    .focused($isTextFieldFocused)
                    .disabled(vm.isInteractingWithChatGPT)
            } else {
                ZStack(alignment: .leading) {
                    if vm.inputMessage.isEmpty && !isTextFieldFocused {
                        Text("Ask us anything!")
                            .foregroundColor(.black)
                            .font(.roboto(.Regular, size: 15)) // Replace here
                    }
                    TextField("", text: $vm.inputMessage)
                        .textFieldStyle(PlainTextFieldStyle())
                        .background(Color.clear)
                        .foregroundColor(.black)
                        .accentColor(Color(red: 194.0 / 255.0, green: 169.0 / 255.0, blue: 250.0 / 255.0, opacity: 1.0))
                        .font(.roboto(.Regular, size: 15)) // Replace here
                        .focused($isTextFieldFocused)
                        .disabled(vm.isInteractingWithChatGPT)
                }
            }

            
            if vm.isInteractingWithChatGPT {
                DotLoadingView().frame(width: 40, height: 30)
            } else {
                Button {
                    Task { @MainActor in
                        isTextFieldFocused = false
                        scrollToBottom(proxy: proxy)
                        do {
                            try await Task.sleep(nanoseconds: 350_000_000)
                            await vm.sendTapped()
                        } catch {
                            await vm.sendTapped()
                        }
                    }
                } label: {
                    Image.init("send2")
                }
                .buttonStyle(.borderless)
                .keyboardShortcut(.defaultAction)
                .foregroundColor(.black)
                .background(Color.clear)
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
            if text.isEmpty { placeholder.foregroundColor(.black) }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit).foregroundColor(.black)
        }
    }
}

