//
//  PlayerViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import UIKit

protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapForwards()
    func didTapBackwards()
    func didChangeVolume(with value: Float)
}

class PlayerViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let controlsView = PlayerControlsView()
    
    weak var dataSource: PlayerDataSource?
    weak var delegate: PlayerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupBarButtons()
        view.addSubview(imageView)
        view.addSubview(controlsView)
        controlsView.delegate = self
        constrainImageView()
        constrainControlsView()
        configure()
    }
    
    private func setupBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.rightBarButtonItems = [shareButton, addButton]
    }
    
    private func constrainImageView() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalToConstant: 420),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func constrainControlsView() {
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsView.topAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    @objc private func didTapAction() {
        
    }
    
    @objc private func didTapAdd() {
        guard let uri = dataSource?.uri else { return }
        let playlistsVC = LibraryPlaylistsViewController()
        let navVC = UINavigationController(rootViewController: playlistsVC)
        playlistsVC.setupUIForModal()
        playlistsVC.selectionHandler = { [weak self] playlist in
            self?.dismiss(animated: true)
            APIManager.shared.addToPlaylist(with: [uri], playlist: playlist) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.showAddedToPlaylistSuccess()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        present(navVC, animated: true)
    }
    
    func configure() {
        let viewModel = PlayerControlsViewModel(title: dataSource?.songName, subtitle: dataSource?.subtitle)
        controlsView.configure(with: viewModel)
        imageView.sd_setImage(with: dataSource?.imageUrl)
        dataSource?.didChange = { [weak self] in
            self?.configure()
        }
    }
    
    private func showAddedToPlaylistSuccess() {
        let alert = UIAlertController(title: "Success", message: "Added track to playlist", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}

extension PlayerViewController: PlayerControlsViewDelegate {
    
    func didTapPlayPause() {
        delegate?.didTapPlayPause()
    }
    
    func didTapForwards() {
        delegate?.didTapForwards()
    }
    
    func didTapBackwards() {
        delegate?.didTapBackwards()
    }
    
    func didSlideVolume(with value: Float) {
        delegate?.didChangeVolume(with: value)
    }
}
