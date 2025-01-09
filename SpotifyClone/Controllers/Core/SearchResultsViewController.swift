//
//  SearchResultsViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func navigateToAlbum(with album: Album)
    func navigateToPlaylist(with playlist: Playlist)
    func navigateToArtist(with artist: Artist)
    func navigateToTrack(with track: Track)
}

enum SearchResult {
    case album(model: Album?)
    case artist(model: Artist?)
    case track(model: Track?)
    case playlist(model: Playlist?)
}

struct SearchSection {
    let title: String
    let results: [SearchResult]
}

class SearchResultsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SearchResultDefaultTableViewCell.self, forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        table.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        table.isHidden = true
        return table
    }()
    
    private var sections: [SearchSection] = []
    weak var delegate: SearchResultsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.center = view.center
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }
    
    func update(with results: [SearchResult]) {
        let albums = results.filter { if case .album = $0 { return true } else { return false } }.compactMap { $0 }
        let artists = results.filter { if case .artist = $0 { return true } else { return false } }.compactMap { $0 }
        let tracks = results.filter { if case .track = $0 { return true } else { return false } }.compactMap { $0 }
        let playlists = results.filter { if case .playlist = $0 { return true } else { return false } }.compactMap { $0 }
        sections = [
            SearchSection(title: "Albums", results: albums),
            SearchSection(title: "Artists", results: artists),
            SearchSection(title: "Tracks", results: tracks),
            SearchSection(title: "Playlists", results: playlists)
        ]
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }
}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row]

        switch result {
        case .album(model: let album):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell() }
            let name = album?.name ?? ""
            let subtitle = album?.artists.first?.name ?? ""
            let image = URL(string: album?.images.first?.url ?? "")
            let viewModel = SearchResultSubtitleTableViewCellViewModel(title: name, subtitle: subtitle, imageURL: image)
            cell.configure(with: viewModel)
            return cell
        case .artist(model: let artist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else { return UITableViewCell() }
            let name = artist?.name ?? ""
            let image = URL(string: artist?.images?.first?.url ?? "")
            let viewModel = SearchResultDefaultTableViewCellViewModel(title: name, imageURL: image)
            cell.configure(with: viewModel)
            return cell
        case .track(model: let track):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell() }
            let name = track?.name ?? ""
            let subtitle = track?.artists.first?.name ?? ""
            let image = URL(string: track?.album.images.first?.url ?? "")
            let viewModel = SearchResultSubtitleTableViewCellViewModel(title: name, subtitle: subtitle, imageURL: image)
            cell.configure(with: viewModel)
            return cell
        case .playlist(model: let playlist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell() }
            let name = playlist?.name ?? ""
            let subtitle = playlist?.owner.displayName ?? ""
            let image = URL(string: playlist?.images?.first?.url ?? "")
            let viewModel = SearchResultSubtitleTableViewCellViewModel(title: name, subtitle: subtitle, imageURL: image)
            cell.configure(with: viewModel)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        switch result {
        case .album(model: let album):
            guard let album else { return }
            delegate?.navigateToAlbum(with: album)
        case .artist(model: let artist):
            guard let artist else { return }
            delegate?.navigateToArtist(with: artist)
        case .track(model: let track):
            guard let track else { return }
            delegate?.navigateToTrack(with: track)
        case .playlist(model: let playlist):
            guard let playlist else { return }
            delegate?.navigateToPlaylist(with: playlist)
        }
    }
}
