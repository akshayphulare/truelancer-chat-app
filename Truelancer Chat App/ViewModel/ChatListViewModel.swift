//
//  ChatListViewModel.swift
//  Truelancer Chat App
//
//  Created by Akshay Phulare on 21/04/25.
//
import Foundation
import Combine

@MainActor
class ChatListViewModel: ObservableObject {
    @Published var channels: [ChannelModel] = []

    private var manager: ChannelManager
    private var cancellables = Set<AnyCancellable>()
    
    // Updated channel names
    private let defaultChannels = ["SupportBot", "SalesBot", "FAQBot"]
//    private let defaultChannels: [String] = []

    init() {
        self.manager = ChannelManager(channelNames: defaultChannels)

        manager.$channels
            .receive(on: DispatchQueue.main)
            .assign(to: \.channels, on: self)
            .store(in: &cancellables)
    }

    func socket(for channel: String) -> ChannelWebSocket? {
        manager.socket(for: channel)
    }

    func updateChannel(name: String, newMessage: String, isIncoming: Bool, isQueued: Bool, markUnread: Bool) {
        manager.updateChannel(name: name, newMessage: newMessage, isIncoming: isIncoming, isQueued: isQueued, markUnread: markUnread)
    }

    func markAsRead(channelName: String) {
        manager.markAsRead(channelName: channelName)
    }
}
