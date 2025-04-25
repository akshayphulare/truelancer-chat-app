//
//  ChannelManager.swift
//  Truelancer Chat App
//
//  Created by Akshay Phulare on 21/04/25.
//


import Foundation

class ChannelManager: ObservableObject {
    @Published var channels: [ChannelModel] = []
    private var sockets: [String: ChannelWebSocket] = [:]

    init(channelNames: [String]) {
        self.channels = channelNames.map { ChannelModel(name: $0) }

        for name in channelNames {
            let socket = ChannelWebSocket(name: name)
            socket.onMessageReceived = { [weak self] text in
                self?.updateChannel(name: name, newMessage: text, isIncoming: true, isQueued: false, markUnread: true)
            }
            sockets[name] = socket
        }
    }

    func updateChannel(name: String, newMessage: String, isIncoming: Bool, isQueued: Bool, markUnread: Bool) {
        if let index = channels.firstIndex(where: { $0.name == name }) {
            let prefix = isQueued ? "🕓" : (isIncoming ? "🔻" : "🔺")
            channels[index].recentMessage = "\(prefix) \(newMessage)"
            if isIncoming && markUnread {
                channels[index].unreadCount += 1
            }
        }
    }

    func markAsRead(channelName: String) {
        if let index = channels.firstIndex(where: { $0.name == channelName }) {
            channels[index].unreadCount = 0
        }
    }

    func socket(for channel: String) -> ChannelWebSocket? {
        return sockets[channel]
    }
}
