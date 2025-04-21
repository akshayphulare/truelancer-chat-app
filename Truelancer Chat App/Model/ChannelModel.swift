//
//  ChannelModel.swift
//  Truelancer Chat App
//
//  Created by Akshay Phulare on 21/04/25.
//


import Foundation

struct ChannelModel: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var recentMessage: String = "No messages yet"
    var unreadCount: Int = 0
}

struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}

