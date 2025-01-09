//
//  MockNetworkManager.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 26/12/24.
//

class MockNetworkManager: NetworkManager {
    var isMockNetworkAvailable = false
    
    override var isNetworkAvailable: Bool {
        get {
            return isMockNetworkAvailable
        }
        set {
            isMockNetworkAvailable = newValue
        }
    }
}
