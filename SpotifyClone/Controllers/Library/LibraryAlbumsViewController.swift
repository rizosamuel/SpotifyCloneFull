//
//  LibraryAlbumsViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 28/12/24.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {
    
    private let noAlbumsView = ActionLabelView()
    
    private var albums: [Album] = []
    
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
        setupLongPressGesture()
        fetchPlaylists()
    }
    
    func fetchPlaylists(needsCache: Bool = false) {
        APIManager.shared.getUsersAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let savedAlbums):
                    self?.albums = savedAlbums.items.map { $0.album }
                    self?.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func setupViews() {
        let viewModel = ActionLabelViewModel(text: "You haven't saved any albums yet.", actionTitle: "Browse")
        noAlbumsView.configure(with: viewModel)
        view.addSubview(noAlbumsView)
        noAlbumsView.translatesAutoresizingMaskIntoConstraints = false
        noAlbumsView.delegate = self
        
        NSLayoutConstraint.activate([
            noAlbumsView.heightAnchor.constraint(equalToConstant: 60),
            noAlbumsView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 20),
            noAlbumsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noAlbumsView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupLongPressGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        tableView.addGestureRecognizer(gesture)
    }
    
    private func updateUI() {
        if albums.isEmpty {
            noAlbumsView.isHidden = false
            tableView.isHidden = true
        } else {
            noAlbumsView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let touchpoint = gesture.location(in: tableView)
        
        guard let indexPath = tableView.indexPathForRow(at: touchpoint) else { return }
        
        let album = albums[indexPath.row]
        let actionSheet = UIAlertController(title: album.name, message: "Remove this album from Library?", preferredStyle: .actionSheet)
        let addAction = UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.removeAlbum(at: indexPath)
        }
        actionSheet.addAction(addAction)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(actionSheet, animated: true)
    }
    
    private func removeAlbum(at indexPath: IndexPath) {
        APIManager.shared.removeSavedAlbum(with: [albums[indexPath.row].id]) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.albums.remove(at: indexPath.item)
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell() }
        let album = albums[indexPath.row]
        let title = album.name
        let subtitle = album.artists.first?.name ?? ""
        let imageUrl = URL(string: album.images.first?.url ?? "")
        let viewModel = SearchResultSubtitleTableViewCellViewModel(title: title, subtitle: subtitle, imageURL: imageUrl)
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let album = albums[indexPath.row]
        let albumVC = AlbumViewController(album: album)
        navigationController?.pushViewController(albumVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            APIManager.shared.removeSavedAlbum(with: []) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.albums.remove(at: indexPath.item)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        completion(true)
                    case .failure(let error):
                        print(error.localizedDescription)
                        completion(false)
                    }
                }
            }
            
        }
        
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension LibraryAlbumsViewController: ActionLabelViewDelegate {
    func didTapButton() {
        //
    }
}
