//
//  ChatListView.swift
//  Truelancer Chat App
//
//  Created by Akshay Phulare on 21/04/25.
//


import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    var body: some View {
        NavigationView {
            if viewModel.channels.isEmpty {
                            NoChatsPlaceholderView()
                                .navigationTitle("Chats")
                                .navigationBarTitleDisplayMode(.inline)
            } else {

                
                List {
                    ForEach(viewModel.channels) { channel in
                        NavigationLink(destination: ChatView(channelName: channel.name, manager: viewModel)) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Text(initials(from: channel.name))
                                            .foregroundColor(.white)
                                            .font(.headline)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(channel.name)
                                            .font(.headline)
                                        Spacer()
                                    }
                                    Text(channel.recentMessage).font(.subheadline).foregroundColor(.gray).lineLimit(1)
                                }

                                if channel.unreadCount > 0 {
                                    Text("\(channel.unreadCount)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.green)
                                        .clipShape(Circle())
                                }
                            }.padding(.vertical, 8)
                        }
                    }
//                    #if targetEnvironment(simulator)
                    Section {
                        Toggle("Simulate Internet", isOn: Binding(
                            get: { networkMonitor.simulatedStatus ?? true },
                            set: { networkMonitor.simulatedStatus = $0 }
                        ))
                        .padding()
                    }
//                    #endif
                }
                .navigationTitle("Chats")
                .navigationBarTitleDisplayMode(.inline)
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
    }

    private func initials(from name: String) -> String {
        let capitalLetters = name.filter { $0.isUppercase }
        return String(capitalLetters.prefix(2))
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

struct NoChatsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)

            Text("No chats available")
                .font(.title3)
                .foregroundColor(.gray)

            Text("Start a new conversation to see it here.")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.7))
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}
