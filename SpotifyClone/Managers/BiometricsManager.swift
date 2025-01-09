//
//  BiometricsManager.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 06/01/25.
//

import Foundation
import LocalAuthentication

enum BiometryType: String {
    case none, touchId, faceId, unknown
}

class BiometricsManager: FileIdentifier {
    static var shared: BiometricsManager!
    
    private let context: LAContext
    private var biometryError: NSError?
    private var currentBiometryType: BiometryType = .none
    private let contextQueue = DispatchQueue(label: "com.myapp.biometricQueue")
    
    static func setupManager(isTesting: Bool = false) {
        let manager = BiometricsManager(context: LAContext())
        BiometricsManager.shared = manager
    }
    
    init(context: LAContext) {
        self.context = context
    }
    
    func isBiometricsEnabled() -> Bool {
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &biometryError) else {
            print("\n[\(fileName)] BIOMETRICS IS NOT AVAILABLE \(getAuthenticationError()))")
            currentBiometryType = .none
            return false
        }
        
        switch context.biometryType {
        case .faceID:
            currentBiometryType = .faceId
        case .touchID:
            currentBiometryType = .touchId
        default:
            currentBiometryType = .unknown
        }
        print("\n[\(fileName)] \(currentBiometryType.rawValue.uppercased()) BIOMETRICS IS AVAILABLE")
        return true
    }
    
    private func getAuthenticationError() -> String {
        guard let laError = biometryError as? LAError else { return "" }
        
        switch laError.code {
        case .authenticationFailed:
            return "Authentication failed"
        case .userCancel:
            return "User cancelled authentication"
        case .userFallback:
            return "User chose password instead"
        case .biometryNotAvailable:
            return "Biometry not available on this device"
        case .biometryNotEnrolled:
            return "User has not enrolled biometric authentication"
        case .biometryLockout:
            return "Biometry is locked out. Use passcode"
        default:
            return "Unknown error: \(laError.localizedDescription)"
        }
    }
    
    func performBiometricScan(completion: @escaping (Bool, String) -> Void) {
        contextQueue.async { [weak self] in
            let reason = "Authenticate to access your data"
            self?.context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.biometryError = error as? NSError
                    completion(success, self.getAuthenticationError())
                }
            }
        }
    }
    
    func resetContext() {
        context.invalidate()
    }
}
