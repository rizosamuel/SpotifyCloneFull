//
//  SearchViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var categories: [Category] = []
    private var searchResults: [SearchResult] = []
    
    private let layout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let groupLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200))
            let itemLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let subItem = NSCollectionLayoutItem(layoutSize: itemLayoutSize)
            subItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 0)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupLayoutSize, subitem: subItem, count: 2)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5)
            return section
        }
        return layout
    }()
    
    private let searchController: UISearchController = {
        let resultsVC = SearchResultsViewController()
        let vc = UISearchController(searchResultsController: resultsVC)
        vc.searchBar.placeholder = "Song, Artist, Album"
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        setupCollectionView()
        fetchData()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
    }
    
    private func fetchData() {
        APIManager.shared.getCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.categories = model.categories.items
                    self?.collectionView.reloadData()
                case .failure(let error):
                    guard let self else { return }
                    let emptyLabelView = EmptyLabelView()
                    emptyLabelView.configure(with: error.localizedDescription)
                    self.view.addSubview(emptyLabelView)
                    emptyLabelView.centerContrainTo(view: self.view)
                }
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let resultsVC = searchController.searchResultsController as? SearchResultsViewController else { return }
        resultsVC.delegate = self
        APIManager.shared.search(with: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    guard let self else { return }
                    let albums: [SearchResult] = result.albums.items.compactMap { .album(model: $0) }
                    let artists: [SearchResult] = result.artists.items.compactMap { .artist(model: $0) }
                    let tracks: [SearchResult] = result.tracks.items.compactMap { .track(model: $0) }
                    let playlists: [SearchResult] = result.playlists.items.compactMap { .playlist(model: $0) }
                    self.searchResults.append(contentsOf: albums)
                    self.searchResults.append(contentsOf: artists)
                    self.searchResults.append(contentsOf: tracks)
                    self.searchResults.append(contentsOf: playlists)
                    resultsVC.update(with: self.searchResults)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let name = categories[indexPath.row].name
        let image = URL(string: categories[indexPath.row].icons.first?.url ?? "")
        let hashtag = "#\(Int.random(in: 1...100))"
        let viewModel = CategoriesCellViewModel(name: name, artworkUrl: image, hashtag: hashtag)
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        collectionView.deselectItem(at: indexPath, animated: true)
        let categoryVC = CategoryViewController(category: categories[indexPath.row])
        navigationController?.pushViewController(categoryVC, animated: true)
    }
}

extension SearchViewController: SearchResultsViewControllerDelegate {
    func navigateToAlbum(with album: Album) {
        let albumVC = AlbumViewController(album: album)
        navigationController?.pushViewController(albumVC, animated: true)
    }
    
    func navigateToPlaylist(with playlist: Playlist) {
        let playlistVC = PlaylistViewController(playlist: playlist)
        navigationController?.pushViewController(playlistVC, animated: true)
    }
    
    func navigateToArtist(with artist: Artist) {
        guard let url = URL(string: artist.externalUrls.spotify) else { return }
        let webVC = SFSafariViewController(url: url)
        present(webVC, animated: true)
    }
    
    func navigateToTrack(with track: Track) {
        let name = track.name
        let subtitle = track.artists.first?.name
        let url = URL(string: track.album.images.first?.url ?? "")
        let uri = track.uri
        let viewModel = PlaybackPresenterViewModel(name: name, subtitle: subtitle, url: url, uri: uri)
        PlaybackPresenter.shared.startPlayback(from: self, viewModel: viewModel)
    }
}
