//
//  PlaylistViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 10/12/24.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    private let playlist: Playlist
    private let collectionView: UICollectionView
    private let emptyLabelView: EmptyLabelView
    
    private var tracks: [TrackItem] = []
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
    
    init(playlist: Playlist) {
        self.playlist = playlist
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.emptyLabelView = EmptyLabelView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        title = playlist.name
        setupCollectionView()
        setupNavigationButton()
        fetchData()
    }
    
    private func fetchData() {
        APIManager.shared.getPlaylistDetails(for: playlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlist):
                    guard let tracks = playlist.tracks, tracks.items.count > 0, let self else {
                        self?.displayEmptyView()
                        return
                    }
                    self.removeEmptyView()
                    self.tracks = self.removeDuplicates(from: tracks.items)
                    self.viewModels = self.tracks.compactMap({ track in
                        let name = track.track?.name ?? ""
                        let artist = track.track?.artists.first?.name ?? "-"
                        let image = URL(string: track.track?.album.images.first?.url ?? "")
                        return TracksCellViewModel(name: name, artistName: artist, artworkUrl: image)
                    })
                    self.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.displayEmptyView()
                }
            }
        }
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
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        collectionView.addGestureRecognizer(gesture)
    }
    
    private func setupNavigationButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
    }
    
    @objc private func didTapShare() {
        guard let url = URL(string: playlist.externalUrls.spotify) else { return }
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
    
    private func removeDuplicates(from tracks: [TrackItem]) -> [TrackItem] {
        var seenIds: [String] = []
        let uniqueTracks = tracks.filter { track in
            guard let id = track.track?.id else { return false }
            if seenIds.contains(id) {
                return false
            } else {
                seenIds.append(id)
                return true
            }
        }
        return uniqueTracks
    }
    
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let touchpoint = gesture.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: touchpoint) else { return }
        
        let model = tracks[indexPath.row].track
        let actionSheet = UIAlertController(title: model?.name, message: "Remove this track from playlist?", preferredStyle: .actionSheet)
        let addAction = UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.removeTrack(at: indexPath)
        }
        actionSheet.addAction(addAction)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(actionSheet, animated: true)
    }
    
    private func removeTrack(at indexPath: IndexPath) {
        guard let uri = tracks[indexPath.row].track?.uri else { return }
        let deletedTrack = ToDeleteTrack(uri: uri)
        APIManager.shared.removeFromPlaylist(with: [deletedTrack], playlist: playlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.viewModels.remove(at: indexPath.item)
                    self?.tracks.remove(at: indexPath.item)
                    self?.collectionView.deleteItems(at: [indexPath])
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        
        let name = playlist.name
        let desc = playlist.description
        let owner = playlist.owner.displayName
        let image = URL(string: playlist.images?.first?.url ?? "")
        let isActive = !tracks.isEmpty
        let viewModel = PlaylistHeaderCollectionReusableViewModel(name: name, owner: owner, description: desc, artworkUrl: image, isActive: isActive)
        header.delegate = self
        header.configure(with: viewModel)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCollectionViewCell.identifier, for: indexPath) as? TrackCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let track = tracks[indexPath.row].track
        let name = track?.name ?? ""
        let subtitle = track?.artists.first?.name
        let url = URL(string: track?.album.images.first?.url ?? "")
        let uri = track?.uri ?? ""
        let viewModel = PlaybackPresenterViewModel(name: name, subtitle: subtitle, url: url, uri: uri)
        PlaybackPresenter.shared.startPlayback(from: self, viewModel: viewModel)
    }
}

extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func didTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        let viewModels = tracks.map { track in
            let name = track.track?.name ?? ""
            let subtitle = track.track?.artists.first?.name
            let url = URL(string: track.track?.album.images.first?.url ?? "")
            let uri = track.track?.uri ?? ""
            return PlaybackPresenterViewModel(name: name, subtitle: subtitle, url: url, uri: uri)
        }
        PlaybackPresenter.shared.startPlayback(from: self, viewModels: viewModels)
    }
}
