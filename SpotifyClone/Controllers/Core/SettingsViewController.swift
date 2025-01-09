//
//  SettingsViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import UIKit

enum Setting {
    case profile(isEnabled: Bool)
    case appLock(isEnabled: Bool)
    case account(isEnabled: Bool)
}

struct Option {
    var isEnabled: Bool = true
    let title: String
    var hasToggle: Bool = false
    var isToggleOn: Bool = false
}

class SettingsViewController: UIViewController, FileIdentifier {
    
    enum AppLockMode {
        case enableAppLock, disableAppLock
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        return tableView
    }()
    
    private let sections: [Setting] = [
        .profile(isEnabled: true),
        .appLock(isEnabled: true),
        .account(isEnabled: true)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func viewProfile() {
        let profileVC = ProfileViewController()
        profileVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    private func signOutTapped() {
        let title = "Are you sure?"
        let message = "You'll need to Re-Login to use Spotify"
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let addAction = UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            guard let self else { return }
            UserDefaults.standard.removeObject(forKey: Constants.IS_APP_LOCK_KEY)
            AuthManager.shared.signOut()
            let navVC = UINavigationController(rootViewController: WelcomeViewController())
            self.resetRootViewController(to: navVC)
            print("\n[\(self.fileName)] YOU HAVE SIGNED OUT")
        }
        actionSheet.addAction(addAction)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(actionSheet, animated: true)
    }
    
    private func performBiometricAuthentication(for appLockMode: AppLockMode, toggle: UISwitch) {
        guard BiometricsManager.shared.isBiometricsEnabled() else { return }
        
        BiometricsManager.shared.performBiometricScan { [weak self] isSuccess, error in
            switch (appLockMode, isSuccess) {
            case (.enableAppLock, true):
                toggle.isOn = true
                UserDefaults.standard.set(true, forKey: Constants.IS_APP_LOCK_KEY)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.showSimpleAlert(with: "Success", message: "You have enabled App lock")
                }
            case (.disableAppLock, true):
                toggle.isOn = false
                UserDefaults.standard.set(false, forKey: Constants.IS_APP_LOCK_KEY)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.showSimpleAlert(with: "Success", message: "You have disabled App lock")
                }
            case (.enableAppLock, false):
                toggle.isOn = false
                UserDefaults.standard.set(false, forKey: Constants.IS_APP_LOCK_KEY)
            case (.disableAppLock, false):
                toggle.isOn = true
                UserDefaults.standard.set(true, forKey: Constants.IS_APP_LOCK_KEY)
            }
        }
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as? SettingsTableViewCell else { return UITableViewCell() }
        let option = sections[indexPath.section].options[indexPath.row]
        cell.configure(with: option, setting: sections[indexPath.section])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let setting = sections[indexPath.section]
        switch setting {
        case .profile: viewProfile()
        case .appLock: break
        case .account: signOutTapped()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

extension SettingsViewController: SettingsTableViewCellDelegate {
    func didToggle(on setting: Setting, _ toggle: UISwitch) {
        switch setting {
        case .appLock:
            let appLockMode: AppLockMode = toggle.isOn ? .enableAppLock : .disableAppLock
            performBiometricAuthentication(for: appLockMode, toggle: toggle)
        default:
            break
        }
    }
}

extension Setting {
    var title: String {
        switch self {
        case .profile: return "Profile"
        case .appLock: return "App Lock"
        case .account: return "Account"
        }
    }
    
    var options: [Option] {
        switch self {
        case .profile:
            return [Option(title: "View your Profile")]
        case .appLock:
            let isAppLock = UserDefaults.standard.bool(forKey: Constants.IS_APP_LOCK_KEY)
            return [Option(title: "Enable Biometrics", hasToggle: true, isToggleOn: isAppLock)]
        case .account:
            return [Option(title: "Sign Out")]
        }
    }
    
    var isToggle: Bool {
        switch self {
        case .profile: return false
        case .appLock: return true
        case .account: return false
        }
    }
}
