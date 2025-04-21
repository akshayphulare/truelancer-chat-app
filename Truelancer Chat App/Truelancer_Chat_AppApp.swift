//
//  Truelancer_Chat_AppApp.swift
//  Truelancer Chat App
//
//  Created by Akshay Phulare on 21/04/25.
//

import SwiftUI

@main
struct Truelancer_Chat_AppApp: App {
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    var body: some Scene {
        WindowGroup {
            ChatListView()
                .environmentObject(networkMonitor)
        }
    }
}
