//
//  ChatViewModel.swift
//  Truelancer Chat App
//
//  Created by Akshay Phulare on 21/04/25.
//

import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var errorMessage: AlertMessage?

    var socketMessages: [ChatMessage] {
        channelSocket.messages
    }

    let channelName: String
    private let channelSocket: ChannelWebSocket
    private let manager: ChatListViewModel

    init(channelName: String, manager: ChatListViewModel) {
        self.channelName = channelName
        self.manager = manager
        self.channelSocket = manager.socket(for: channelName)!

        self.channelSocket.onMessageReceived = { [weak self] text in
            guard let self else { return }
            self.manager.updateChannel(name: channelName, newMessage: text, isIncoming: true, isQueued: false)
        }

        self.channelSocket.onError = { [weak self] error in
            self?.errorMessage = AlertMessage(message: error.localizedDescription)
        }
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        channelSocket.send(text)
        let isQueued = !NetworkMonitor.shared.effectiveConnectionStatus
        manager.updateChannel(name: channelName, newMessage: text, isIncoming: false, isQueued: isQueued)
        inputText = ""
    }

    func markAsRead() {
        manager.markAsRead(channelName: channelName)
    }
}
