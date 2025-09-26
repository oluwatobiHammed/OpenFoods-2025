//
//  NetworkMonitor.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-26.
//


// MARK: - Network Reachability
import Network
import SwiftUI

/**
 A lightweight, observable reachability helper that reports whether the device currently has network connectivity.
 
 NetworkMonitor wraps `NWPathMonitor` from the Network framework and exposes a single `@Published` boolean (`isConnected`) that updates on the main thread whenever connectivity changes. It is suitable for driving SwiftUI UI state (e.g., showing an offline banner) or for gating network requests.
 
 - Features:
 - Uses `NWPathMonitor` to observe path changes system-wide.
 - Publishes connectivity changes via `@Published` for SwiftUI/Combine.
 - Dispatches updates to the main thread to keep UI bindings safe.
 - Starts monitoring on initialization and stops automatically on deallocation.
 
 - Threading:
 - Path monitoring runs on a private background `DispatchQueue`.
 - The `isConnected` property is always updated on the main queue.
 
 - Lifecycle:
 - Monitoring begins in `init()` by calling `monitor.start(queue:)`.
 - Monitoring is cancelled in `deinit` to free resources.
 
 - Availability:
 - Requires the Network framework (`import Network`).
 - `NWPathMonitor` is available on iOS 12.0+, iPadOS 12.0+, macOS 10.14+, tvOS 12.0+, watchOS 5.0+.
 
 - Example (SwiftUI):
 ```swift
 import SwiftUI
 
 struct ContentView: View {
 @StateObject private var network = NetworkMonitor()
 
 var body: some View {
 VStack {
               if network.isConnected {
                   Text("Online")
               } else {
                   Text("Offline")
               }
           }
       }
   }
 */


class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = false
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
