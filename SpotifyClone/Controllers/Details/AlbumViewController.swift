//
//  AlbumViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 10/12/24.
//

import UIKit

class AlbumViewController: UIViewController {
    
    private let album: Album
    private let collectionView: UICollectionView
    private let emptyLabelView: EmptyLabelView
    
    private var tracks: [AlbumTrack] = []
    private var viewModels: [TracksCellViewModel] = []
    
    private let layout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let verticalGroupLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
            let itemLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let subItem = NSCollectionLayoutItem(layoutSize: itemLayoutSize)
            subItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5)
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupLayoutSize, subitem: subItem, count: 1)
            let section = NSCollectionLayoutSection(group: verticalGroup)
            let boundaryLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(400))
            let kind = UICollectionView.elementKindSectionHeader
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryLayoutSize, elementKind: kind, alignment: .top)
            section.boundarySupplementaryItems = [headerItem]
            return section
        }
        return layout
    }()
    
    init(album: Album) {
        self.album = album
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.emptyLabelView = EmptyLabelView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        setupAddButton()
        setupCollectionView()
        fetchData()
        setupLongPressGesture()
    }
    
    private func setupAddButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func didTapAdd() {
        APIManager.shared.saveAlbum(with: [album.id]) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    HapticsManager.shared.vibrate(for: .success)
                    let title = "Success"
                    let message = "Saved album to Library"
                    self?.showSimpleAlert(with: title, message: message)
                case .failure(let error):
                    HapticsManager.shared.vibrate(for: .error)
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchData() {
        APIManager.shared.getAlbumDetails(for: album) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let album):
                    self?.tracks = album.tracks.items
                    self?.viewModels = album.tracks.items.compactMap({ track in
                        let name = track.name
                        let artist = track.artists.first?.name ?? "-"
                        return TracksCellViewModel(name: name, artistName: artist, artworkUrl: nil)
                    })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    self?.displayEmptyView()
                }
            }
        }
    }
    
    private func setupCollectionView() {
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            PlaylistHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier
        )
        collectionView.register(TrackCollectionViewCell.self, forCellWithReuseIdentifier: TrackCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func displayEmptyView() {
        removeEmptyView()
        collectionView.addSubview(emptyLabelView)
        emptyLabelView.configure(with: "No tracks to display")
        emptyLabelView.centerContrainTo(view: collectionView, centerY: 100)
    }
    
    private func removeEmptyView() {
        emptyLabelView.removeFromSuperview()
    }
    
    private func setupLongPressGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let touchpoint = gesture.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: touchpoint) else { return }
        
        let model = tracks[indexPath.row]
        let actionSheet = UIAlertController(title: model.name, message: "Add this track to playlist?", preferredStyle: .actionSheet)
        let addAction = UIAlertAction(title: "Add to Playlist", style: .default) { [weak self] _ in
            self?.showLibraryPlaylists(with: model)
        }
        actionSheet.addAction(addAction)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(actionSheet, animated: true)
    }
    
    private func showLibraryPlaylists(with model: AlbumTrack) {
        let playlistVC = LibraryPlaylistsViewController()
        let navVC = UINavigationController(rootViewController: playlistVC)
        playlistVC.setupUIForModal()
        playlistVC.selectionHandler = { [weak self] playlist in
            self?.dismiss(animated: true)
            APIManager.shared.addToPlaylist(with: [model.uri], playlist: playlist) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        let title = "Success"
                        let message = "Added Track to playlist \(playlist.name)"
                        self?.showSimpleAlert(with: title, message: message)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        present(navVC, animated: true)
    }
}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier, for: indexPath) as? PlaylistHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        
        let name = album.name
        let desc = "Release Date: \(album.releaseDate.toFormattedDateString)"
        let owner = album.artists.first?.name ?? "-"
        let url = URL(string: album.images.first?.url ?? "")
        let isActive = !tracks.isEmpty
        let viewModel = PlaylistHeaderCollectionReusableViewModel(name: name, owner: owner, description: desc, artworkUrl: url, isActive: isActive)
        header.delegate = self
        header.configure(with: viewModel)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCollectionViewCell.identifier, for: indexPath) as? TrackCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(with: viewModels[indexPath.row], needsArtwork: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let track = tracks[indexPath.row]
        let name = track.name
        let subtitle = track.artists.first?.name
        let url = URL(string: album.images.first?.url ?? "")
        let viewModel = PlaybackPresenterViewModel(name: name, subtitle: subtitle, url: url, uri: track.uri)
        PlaybackPresenter.shared.startPlayback(from: self, viewModel: viewModel)
    }
}

extension AlbumViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func didTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        let viewModels = tracks.map { track in
            let name = track.name
            let subtitle = track.artists.first?.name
            let url = URL(string: album.images.first?.url ?? "")
            return PlaybackPresenterViewModel(name: name, subtitle: subtitle, url: url, uri: track.uri)
        }
        PlaybackPresenter.shared.startPlayback(from: self, viewModels: viewModels)
    }
}
