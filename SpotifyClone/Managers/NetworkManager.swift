//
//  NetworkManager.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 16/12/24.
//

import Network

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    var isNetworkAvailable: Bool = false
    var connectionType: NWInterface.InterfaceType?

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isNetworkAvailable = path.status == .satisfied
            self?.connectionType = path.availableInterfaces.first(where: { path.usesInterfaceType($0.type) })?.type
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
