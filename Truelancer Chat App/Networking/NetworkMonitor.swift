//
//  NetworkMonitor.swift
//  Truelancer Chat App
//
//  Created by Akshay Phulare on 21/04/25.
//

import Foundation
import Network
import Combine

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published private(set) var isConnected: Bool = true
    @Published var simulatedStatus: Bool? = nil

    // This triggers both real and simulated updates
    @Published var connectionStatusForSocket: Bool = true

    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Real network status changes
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                guard let self else { return }

                print("📶 Real path update: \(path.status)")
                self.isConnected = path.status == .satisfied
                self.updateEffectiveStatus()
            }
        }

        monitor.start(queue: queue)

        // Simulation changes (e.g. from toggle)
        $simulatedStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateEffectiveStatus()
            }
            .store(in: &cancellables)
    }

    /// Simulated OR real connection status — used in UI and WebSockets
    var effectiveConnectionStatus: Bool {
        simulatedStatus ?? isConnected
    }

    private func updateEffectiveStatus() {
        connectionStatusForSocket = effectiveConnectionStatus
    }
}
