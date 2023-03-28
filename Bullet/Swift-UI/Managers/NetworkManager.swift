//
//  NetworkManager.swift
//  NewsReels
//
//  Created by Yeshua Lagac on 2/28/22.
//
// Source: https://medium.com/free-code-camp/how-to-handle-internet-connection-reachability-in-swift-34482301ea57

import Foundation
import Reachability

class NetworkManager: NSObject {
    var reachability: Reachability!
    static let shared: NetworkManager = {
        return NetworkManager()
    }()
    override init() {
        super.init()
        // Initialise reachability
        if let reachability = try? Reachability() {
            self.reachability = reachability
        } else {
            fatalError("Failed to initialize reachability")
        }
        // Register an observer for the network status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        do {
            // Start the network status notifier
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    @objc func networkStatusChanged(_ notification: Notification) {
        // Do something globally here!
    }
    static func stopNotifier() -> Void {
        do {
            // Stop the network status notifier
            try (NetworkManager.shared.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }

    // Network is reachable
    static var isReachable: Bool {
        return (NetworkManager.shared.reachability).connection != .unavailable
    }
    // Network is unreachable
    static var isUnreachable: Bool {
        return (NetworkManager.shared.reachability).connection == .unavailable
    }
    // Network is reachable via WWAN/Cellular
    static var isReachableViaWWAN: Bool {
        return (NetworkManager.shared.reachability).connection == .cellular
    }
    // Network is reachable via WiFi
    static var isReachableViaWiFi: Bool {
        return (NetworkManager.shared.reachability).connection == .wifi
    }
}
