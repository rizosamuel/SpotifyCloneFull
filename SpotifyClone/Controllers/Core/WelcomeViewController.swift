//
//  WelcomeViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBackground
        button.setTitle("Sign In with Spotify", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()
    
    private let backgroundImage: UIImageView = {
        let image = UIImageView(image: .collage)
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        view.alpha = 0.5
        return view
    }()
    
    private let logoView: UIImageView = {
        let image = UIImageView(image: .pngLogo)
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .heavy)
        label.text = "Listen to millions of songs on the go"
        label.textColor = .systemBackground
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Spotify"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .label
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        view.addSubview(backgroundImage)
        backgroundImage.frame = view.bounds
        
        view.addSubview(overlayView)
        overlayView.frame = view.bounds
        
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        constrainSignInButton()
        
        view.addSubview(logoView)
        logoView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        logoView.center = view.center
        
        view.addSubview(titleLabel)
        titleLabel.frame = CGRect(x: 20, y: logoView.bottom + 20, width: view.frame.size.width - 40, height: 100)
    }
    
    private func constrainSignInButton() {
        NSLayoutConstraint.activate([
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            signInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func didTapSignIn() {
        let authVC = AuthViewController()
        authVC.isAsync = true
        authVC.completion = { [weak self] success in
            self?.handleSignIn(success: success)
        }
        present(authVC, animated: true)
    }
    
    private func handleSignIn(success: Bool) {
        guard success else {
            let alert = UIAlertController(title: "Oops", message: "Something went wrong while signing in", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            return
        }
        
        dismiss(animated: true) { [weak self] in
            self?.resetRootViewController(to: TabBarController())
        }
    }
}
