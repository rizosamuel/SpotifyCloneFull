//
//  LibraryViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import UIKit

class LibraryViewController: UIViewController {
    
    private let libraryPlaylistsVC = LibraryPlaylistsViewController()
    private let libraryAlbumsVC = LibraryAlbumsViewController()
    
    private let libScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private let toggleView = LibraryToggleView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(toggleView)
        view.addSubview(libScrollView)
        libScrollView.delegate = self
        toggleView.delegate = self
        
        constrainToggleView()
        constrainScrollView()
        addChildren()
        toggleBarButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        libScrollView.contentSize = CGSize(width: libScrollView.width * 2, height: libScrollView.height)
    }
    
    private func constrainToggleView() {
        toggleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toggleView.heightAnchor.constraint(equalToConstant: 50),
            toggleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            toggleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            toggleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toggleView.bottomAnchor.constraint(equalTo: libScrollView.topAnchor)
        ])
        toggleView.layer.cornerRadius = 25
        toggleView.layer.masksToBounds = true
    }
    
    private func constrainScrollView() {
        NSLayoutConstraint.activate([
            libScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            libScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            libScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
    private func addChildren() {
        addChild(libraryPlaylistsVC)
        libScrollView.addSubview(libraryPlaylistsVC.view)
        libraryPlaylistsVC.view.frame = CGRect(x: 0, y: 0, width: libScrollView.width, height: libScrollView.height)
        libraryPlaylistsVC.didMove(toParent: self)
        
        addChild(libraryAlbumsVC)
        libScrollView.addSubview(libraryAlbumsVC.view)
        libraryAlbumsVC.view.frame = CGRect(x: view.width, y: 0, width: libScrollView.width, height: libScrollView.height)
        libraryAlbumsVC.didMove(toParent: self)
    }
    
    private func toggleBarButton() {
        switch toggleView.getState() {
        case .playlists:
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddPlaylist))
            navigationItem.rightBarButtonItem = addButton
        case .albums:
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func didTapAddPlaylist() {
        libraryPlaylistsVC.presentInputActionSheet { [weak self] name, desc in
            APIManager.shared.createPlaylist(with: name, desc: desc) { result in
                switch result {
                case .success:
                    self?.libraryPlaylistsVC.fetchPlaylists()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension LibraryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= (view.width - 100) {
            toggleView.updateState(with: .albums)
            toggleBarButton()
        } else {
            toggleView.updateState(with: .playlists)
            toggleBarButton()
        }
    }
}

extension LibraryViewController: LibraryToggleViewDelegate {
    func didTapPlaylists() {
        libScrollView.setContentOffset(.zero, animated: true)
        toggleBarButton()
    }
    
    func didTapAlbums() {
        libScrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        toggleBarButton()
    }
}
