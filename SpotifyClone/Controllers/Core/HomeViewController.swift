//
//  HomeViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import UIKit

enum BrowseSectionType {
    case newReleases(viewModels: [NewReleasesCellViewModel])
    case playlists(viewModels: [CurrentPlaylistsCellViewModel])
    case categories(viewModels: [CategoriesCellViewModel])
    case recommendedTracks(viewModels: [TracksCellViewModel])
    
    var title: String {
        switch self {
        case .newReleases: return "New Releases"
        case .playlists: return "Current Playlist"
        case .categories: return "Categories"
        case .recommendedTracks: return "Liked Tracks"
        }
    }
}

class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView?
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var sections = [BrowseSectionType]()
    private var albums = [Album]()
    private var playlists = [Playlist]()
    private var categories = [Category]()
    private var tracks = [TrackItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let gearButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "gear"), target: self, action: #selector(didTapSettings))
        navigationItem.rightBarButtonItem = gearButton
        
        setupCollectionView()
        configureCollectionView()
        fetchData()
        view.addSubview(spinner)
        
        BiometricsManager.shared.isBiometricsEnabled()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            self?.createSectionLayout(section: sectionIndex)
        }
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    }
    
    private func configureCollectionView() {
        guard let collectionView else { return }
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(CurrentPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: CurrentPlaylistCollectionViewCell.identifier)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.register(TrackCollectionViewCell.self, forCellWithReuseIdentifier: TrackCollectionViewCell.identifier)
        collectionView.register(TitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func fetchData() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        var newReleases: NewReleases?
        var currentPlaylists: CurrentPlaylists?
        var categories: CategoriesResponse?
        var tracks: TracksResponse?
        
        APIManager.shared.getNewReleases { result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let releases):
                newReleases = releases
            case .failure(let error):
                print("Could not get new releases \(error.localizedDescription)")
            }
        }
        
        APIManager.shared.getCurrentPlaylists { result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let playlists):
                currentPlaylists = playlists
            case .failure(let error):
                print("Could not get current playlists \(error.localizedDescription)")
            }
        }
        
        APIManager.shared.getCategories { result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let categoriesResult):
                categories = categoriesResult
            case .failure(let error):
                print("Could not get categories \(error.localizedDescription)")
            }
        }
        
        APIManager.shared.getTracks { result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let tracksResult):
                tracks = tracksResult
            case .failure(let error):
                print("Could not get tracks \(error.localizedDescription)")
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let newReleases, let currentPlaylists, let categories, let tracks else { return }
            self?.configureModels(
                albums: newReleases.albums.items,
                playlists: currentPlaylists.items,
                categories: categories.categories.items,
                tracks: tracks.items
            )
        }
    }
    
    private func configureModels(albums: [Album], playlists: [Playlist], categories: [Category], tracks: [TrackItem]) {
        self.albums = albums
        self.playlists = playlists
        self.categories = categories
        self.tracks = tracks
        
        let newReleasesViewModels = albums.compactMap { album in
            let name = album.name
            let image = URL(string: album.images.first?.url ?? "")
            let num = album.totalTracks
            let artistName = album.artists.first?.name ?? "-"
            return NewReleasesCellViewModel(name: name, artworkUrl: image, numberOfTracks: num, artistName: artistName)
        }
        
        let currentPlaylistsViewModels = playlists.compactMap { playlist in
            let name = playlist.name
            let image = URL(string: playlist.images?.first?.url ?? "")
            let owner = playlist.owner.displayName
            return CurrentPlaylistsCellViewModel(name: name, artworkUrl: image, ownerName: owner)
        }
        
        let categoriesViewModels = categories.compactMap { category in
            let name = category.name
            let image = URL(string: category.icons.first?.url ?? "")
            let hashtag = "#\(Int.random(in: 1...100))"
            return CategoriesCellViewModel(name: name, artworkUrl: image, hashtag: hashtag)
        }
        
        let tracksViewModels = tracks.compactMap { track in
            let name = track.track?.name ?? "-"
            let artistName = track.track?.artists.first?.name ?? "-"
            let image = URL(string: track.track?.album.images.first?.url ?? "")
            return TracksCellViewModel(name: name, artistName: artistName, artworkUrl: image)
        }
        
        sections.append(.newReleases(viewModels: newReleasesViewModels))
        sections.append(.playlists(viewModels: currentPlaylistsViewModels))
        sections.append(.categories(viewModels: categoriesViewModels))
        sections.append(.recommendedTracks(viewModels: tracksViewModels))
        collectionView?.reloadData()
    }
    
    @objc func didTapSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}

// MARK: - Collection View Delegates
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = sections[section]
        switch section {
        case .newReleases(viewModels: let viewModels):
            return viewModels.count
        case .playlists(viewModels: let viewModels):
            return viewModels.count
        case .categories(viewModels: let viewModels):
            return viewModels.count
        case .recommendedTracks(viewModels: let viewModels):
            return viewModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        switch type {
        case .newReleases(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCollectionViewCell.identifier, for: indexPath) as? NewReleaseCollectionViewCell else { return UICollectionViewCell() }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        case .playlists(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrentPlaylistCollectionViewCell.identifier, for: indexPath) as? CurrentPlaylistCollectionViewCell else { return UICollectionViewCell() }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        case .categories(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        case .recommendedTracks(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCollectionViewCell.identifier, for: indexPath) as? TrackCollectionViewCell else { return UICollectionViewCell() }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let section = sections[indexPath.section]
        switch section {
        case .newReleases:
            let album = albums[indexPath.row]
            let albumVC = AlbumViewController(album: album)
            navigationController?.pushViewController(albumVC, animated: true)
        case .playlists:
            let playlist = playlists[indexPath.row]
            let playlistVC = PlaylistViewController(playlist: playlist)
            navigationController?.pushViewController(playlistVC, animated: true)
        case .categories:
            let category = categories[indexPath.row]
            let categoryVC = CategoryViewController(category: category)
            navigationController?.pushViewController(categoryVC, animated: true)
        case .recommendedTracks:
            let track = tracks[indexPath.row].track
            let name = track?.name ?? ""
            let subtitle = track?.artists.first?.name
            let url = URL(string: track?.album.images.first?.url ?? "")
            let uri = track?.uri ?? ""
            let viewModel = PlaybackPresenterViewModel(name: name, subtitle: subtitle, url: url, uri: uri)
            PlaybackPresenter.shared.startPlayback(from: self, viewModel: viewModel)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }

        header.configure(with: sections[indexPath.section].title)
        return header
    }
}

// MARK: - Create Sections
private extension HomeViewController {
    func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        switch section {
        case 0:
            let horizontalGroupLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(390))
            let verticalGroupLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(390))
            let itemLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let subItem = NSCollectionLayoutItem(layoutSize: itemLayoutSize)
            subItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0)
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupLayoutSize, subitem: subItem, count: 3)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupLayoutSize, subitem: verticalGroup, count: 1)
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 10)
            section.boundarySupplementaryItems = [getSectionHeader()]
            return section
        case 1:
            let horizontalGroupLayoutSize = NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400))
            let verticalGroupLayoutSize = NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400))
            let itemLayoutSize = NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(200))
            let subItem = NSCollectionLayoutItem(layoutSize: itemLayoutSize)
            subItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0)
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupLayoutSize, subitem: subItem, count: 2)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupLayoutSize, subitem: verticalGroup, count: 1)
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 10)
            section.boundarySupplementaryItems = [getSectionHeader()]
            return section
        case 2:
            let horizontalGroupLayoutSize = NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400))
            let verticalGroupLayoutSize = NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400))
            let itemLayoutSize = NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(200))
            let subItem = NSCollectionLayoutItem(layoutSize: itemLayoutSize)
            subItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0)
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupLayoutSize, subitem: subItem, count: 2)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupLayoutSize, subitem: verticalGroup, count: 1)
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 10)
            section.boundarySupplementaryItems = [getSectionHeader()]
            return section
        case 3:
            let verticalGroupLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
            let itemLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let subItem = NSCollectionLayoutItem(layoutSize: itemLayoutSize)
            subItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 0)
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupLayoutSize, subitem: subItem, count: 1)
            let section = NSCollectionLayoutSection(group: verticalGroup)
            section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 10)
            section.boundarySupplementaryItems = [getSectionHeader()]
            return section
        default:
            let groupLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
            let itemLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let subItem = NSCollectionLayoutItem(layoutSize: itemLayoutSize)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupLayoutSize, subitem: subItem, count: 1)
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [getSectionHeader()]
            return section
        }
    }
    
    func getSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerlayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
        let kind = UICollectionView.elementKindSectionHeader
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerlayoutSize, elementKind: kind, alignment: .top)
        return header
    }
}
