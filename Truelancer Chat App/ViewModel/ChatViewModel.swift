//
//  ChatViewModel.swift
//  Truelancer Chat App
//
//  Created by Akshay Phulare on 21/04/25.
//

import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var errorMessage: AlertMessage?

//    var socketMessages: [ChatMessage] {
//        channelSocket.messages
//    }
    @Published var socketMessages: [ChatMessage] = []
    private var cancellable: AnyCancellable?
    @Published var isActive = false

    let channelName: String
    private let channelSocket: ChannelWebSocket
    private let manager: ChatListViewModel

    init(channelName: String, manager: ChatListViewModel) {
        self.channelName = channelName
        self.manager = manager
        self.channelSocket = manager.socket(for: channelName)!

        self.channelSocket.onMessageReceived = { [weak self] text in
            guard let self else { return }

            let isUnread = !self.isActive
            self.manager.updateChannel(name: channelName, newMessage: text, isIncoming: true, isQueued: false, markUnread: isUnread)
        }

        self.channelSocket.onError = { [weak self] error in
            self?.errorMessage = AlertMessage(message: error.localizedDescription)
        }
        
        self.channelSocket.onQueueMessageSent = { [weak self] text in
            guard let self else { return }
            
            let isUnread = !self.isActive
            self.manager.updateChannel(name: channelName, newMessage: text, isIncoming: false, isQueued: false, markUnread: isUnread)
        }
        
        self.cancellable = channelSocket.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newMessages in
                self?.socketMessages = newMessages
            }

    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        channelSocket.send(text)
        let isQueued = !NetworkMonitor.shared.effectiveConnectionStatus
        manager.updateChannel(name: channelName, newMessage: text, isIncoming: false, isQueued: isQueued, markUnread: false)
        inputText = ""
    }

    func markAsRead() {
        manager.markAsRead(channelName: channelName)
    }
}
