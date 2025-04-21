//
//  ChatView.swift
//  Truelancer Chat App
//
//  Created by Akshay Phulare on 21/04/25.
//


import SwiftUI

//struct ChatView: View {
//    @StateObject private var viewModel: ChatViewModel
//
//    init(channelName: String, manager: ChatListViewModel) {
//        _viewModel = StateObject(wrappedValue: ChatViewModel(channelName: channelName, manager: manager))
//    }
//
//    var body: some View {
//        VStack {
//            ScrollView {
//                LazyVStack(alignment: .leading) {
//                    ForEach(viewModel.messages, id: \.self) { message in
//                        Text(message)
//                            .padding(8)
//                            .background(Color.gray.opacity(0.15))
//                            .cornerRadius(8)
//                    }
//                }.padding()
//            }
//
//            HStack {
//                TextField("Message...", text: $viewModel.inputText)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//
//                Button("Send") {
//                    viewModel.sendMessage()
//                }
//            }.padding()
//        }
//        .navigationTitle(viewModel.channelName)
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            viewModel.markAsRead()
//        }
//    }
//}


struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    init(channelName: String, manager: ChatListViewModel) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(channelName: channelName, manager: manager))
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(Array(viewModel.socketMessages.enumerated()), id: \.element.id) { index, message in
                            HStack {
                                if message.isSentByUser {
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(message.text)
                                            .padding()
                                            .background(message.isQueued ? Color.orange.opacity(0.8) : Color.green.opacity(0.8))
                                            .foregroundColor(.white)
                                            .cornerRadius(16)

                                        if message.isQueued {
                                            Image(systemName: "clock")
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                } else {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(message.text)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(16)
                                    }
                                    Spacer()
                                }
                            }
                            .id(index)
                            .padding(.horizontal)
                        }
                    }
                }
                .onChange(of: viewModel.socketMessages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.socketMessages.count - 1, anchor: .bottom)
                    }
                }
            }

            Divider()

            HStack(spacing: 12) {
                TextField("Type a message", text: $viewModel.inputText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())

                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.channelName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.markAsRead()
        }
        .alert(item: $viewModel.errorMessage) { alert in
            Alert(
                title: Text("Connection Error"),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text(networkMonitor.effectiveConnectionStatus ? "Online" : "Offline")
                    .font(.caption)
                    .padding(6)
                    .background(networkMonitor.effectiveConnectionStatus ? Color.green : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}
