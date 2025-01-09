//
//  BiometricsViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 08/01/25.
//

import UIKit

class BiometricsViewController: UIViewController {
    
    private let lockImage: UIImageView = {
        let image = UIImageView(image: .lock)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Unlock Spotify to enjoy your music"
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        return label
    }()
    
    private let unlockButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Unlock", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        
        unlockButton.addTarget(self, action: #selector(didTapUnlock), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    private func setupViews() {
        view.addSubview(lockImage)
        view.addSubview(label)
        view.addSubview(unlockButton)
        
        NSLayoutConstraint.activate([
            lockImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lockImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            lockImage.heightAnchor.constraint(equalToConstant: 150),
            lockImage.widthAnchor.constraint(equalToConstant: 150),
            label.topAnchor.constraint(equalTo: lockImage.bottomAnchor, constant: 30),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            unlockButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            unlockButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performBiometricAuthentication()
    }
    
    @objc private func didTapUnlock() {
        performBiometricAuthentication()
    }
    
    @objc private func appDidEnterForeground() {
        performBiometricAuthentication()
    }
    
    private func performBiometricAuthentication() {
        guard BiometricsManager.shared.isBiometricsEnabled() else { return }
        
        BiometricsManager.shared.performBiometricScan { [weak self] isSuccess, error in
            if isSuccess {
                self?.showDashboard()
            } else {
                print(error)
            }
        }
    }
    
    private func showDashboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.resetRootViewController(to: TabBarController())
        }
    }
}
