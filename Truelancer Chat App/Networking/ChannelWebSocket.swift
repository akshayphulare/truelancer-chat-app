//
//  ChannelWebSocket.swift
//  Truelancer Chat App
//
//  Created by Akshay Phulare on 21/04/25.
//

import Foundation
import Combine

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isSentByUser: Bool
    let isQueued: Bool
}

class ChannelWebSocket: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    let name: String
    let url: URL

    @Published var messages: [ChatMessage] = []
    var onMessageReceived: ((String) -> Void)?
    var onError: ((Error) -> Void)?

    private var monitor = NetworkMonitor.shared
    private var cancellable: AnyCancellable?
    private var messageQueue: [String] = []

    init(name: String) {
        self.name = name
        self.url = Constants.socketURL(for: name)
        connect()

        cancellable = monitor.$connectionStatusForSocket
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                if isConnected {
                    self.connect()
                    self.flushMessageQueue()
                } else {
                    self.disconnect()
                }
            }
    }

    private func connect() {
        if let task = webSocketTask, task.state == .running {
            print("🔄 Already connected")
            return
        }
        disconnect()

        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        listen()
    }

    func send(_ message: String) {
        let isOffline = !monitor.effectiveConnectionStatus

        if isOffline {
            print("📥 Queued (offline): \(message)")
            messageQueue.append(message)
            messages.append(ChatMessage(text: message, isSentByUser: true, isQueued: true))
            return
        }

        // ✅ Add optimistically
        messages.append(ChatMessage(text: message, isSentByUser: true, isQueued: false))

        webSocketTask?.send(.string(message)) { [weak self] error in
            if let error = error {
                print("Send error: \(error)")
                self?.onError?(error)
            }
        }
    }

    private func flushMessageQueue() {
        guard !messageQueue.isEmpty else { return }

        print("📤 Flushing \(messageQueue.count) queued messages...")

        let queued = messageQueue
        messageQueue.removeAll()

        for message in queued {
            webSocketTask?.send(.string(message)) { [weak self] error in
                guard let self = self else { return }

                if let error = error {
                    print("Send error during flush: \(error)")
                    self.onError?(error)
                } else {
                    DispatchQueue.main.async {
                        // ✅ Replace the queued message with a non-queued version
                        if let index = self.messages.firstIndex(where: { $0.text == message && $0.isQueued }) {
                            self.messages[index] = ChatMessage(text: message, isSentByUser: true, isQueued: false)
                        }
                    }
                }
            }
        }
    }

    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.onError?(error)
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self.messages.append(ChatMessage(text: text, isSentByUser: false, isQueued: false))
                        self.onMessageReceived?(text)
                    }
                default:
                    break
                }
                self.listen()
            }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }

    deinit {
        disconnect()
        cancellable?.cancel()
    }
}
