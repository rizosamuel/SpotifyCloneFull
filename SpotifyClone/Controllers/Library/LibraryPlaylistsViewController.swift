//
//  LibraryPlaylistsViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 28/12/24.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController {
    
    private let noPlaylistsView = ActionLabelView()
    
    private var playlists: [Playlist] = []
    
    var selectionHandler: ((Playlist) -> Void)?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = false
        table.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        table.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupViews()
        fetchPlaylists()
    }
    
    func fetchPlaylists(needsCache: Bool = false) {
        APIManager.shared.getCurrentPlaylists(needsCache: needsCache) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    print("Playlists", playlists)
                    self.playlists = playlists.items
                    self.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func setupViews() {
        let viewModel = ActionLabelViewModel(text: "You don't have any playlists yet.", actionTitle: "Create")
        noPlaylistsView.configure(with: viewModel)
        view.addSubview(noPlaylistsView)
        noPlaylistsView.translatesAutoresizingMaskIntoConstraints = false
        noPlaylistsView.delegate = self
        
        NSLayoutConstraint.activate([
            noPlaylistsView.heightAnchor.constraint(equalToConstant: 60),
            noPlaylistsView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 20),
            noPlaylistsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noPlaylistsView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func updateUI() {
        if playlists.isEmpty {
            noPlaylistsView.isHidden = false
            tableView.isHidden = true
        } else {
            noPlaylistsView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    func setupUIForModal() {
        title = "Select Playlist"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
}

extension LibraryPlaylistsViewController: ActionLabelViewDelegate {
    func didTapButton() {
        presentInputActionSheet { [weak self] name, description in
            APIManager.shared.createPlaylist(with: name, desc: description) { result in
                switch result {
                case .success:
                    HapticsManager.shared.vibrate(for: .success)
                    self?.fetchPlaylists(needsCache: false)
                case .failure(let error):
                    HapticsManager.shared.vibrate(for: .error)
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func presentInputActionSheet(completion: @escaping (_ name: String, _ desc: String) -> Void) {
        let title = "Create new Playlist"
        let message = "Please provide a name and description."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "enter name..."
        }
        alertController.addTextField { textField in
            textField.placeholder = "enter description..."
        }
        
        let submitAction = UIAlertAction(title: "Create", style: .default) { _ in
            let name = alertController.textFields?[0].text ?? ""
            let description = alertController.textFields?[1].text ?? ""
            completion(name, description)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

extension LibraryPlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell() }
        let playlist = playlists[indexPath.row]
        let title = playlist.name
        let subtitle = playlist.owner.displayName
        let imageUrl = URL(string: playlist.images?.first?.url ?? "")
        let viewModel = SearchResultSubtitleTableViewCellViewModel(title: title, subtitle: subtitle, imageURL: imageUrl)
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selectionHandler {
            selectionHandler(playlists[indexPath.row])
            return
        }
        
        let playlist = playlists[indexPath.row]
        let playlistVC = PlaylistViewController(playlist: playlist)
        navigationController?.pushViewController(playlistVC, animated: true)
    }
}
