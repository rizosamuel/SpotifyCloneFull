//
//  LibraryToggleView.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 28/12/24.
//

import UIKit

protocol LibraryToggleViewDelegate: AnyObject {
    func didTapPlaylists()
    func didTapAlbums()
}

class LibraryToggleView: UIView {
    
    private let playlistsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Playlists", for: .normal)
        return button
    }()
    
    private let albumsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Albums", for: .normal)
        return button
    }()
    
    private let leftUnderlight: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    private let rightUnderlight: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    weak var delegate: LibraryToggleViewDelegate?
    
    private var state: State = .playlists {
        didSet {
            toggleUnderlights()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        setupSubviews()
        
        playlistsButton.addTarget(self, action: #selector(didTapPlaylists), for: .touchUpInside)
        albumsButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        state = .playlists
    }
    
    func updateState(with state: State) {
        self.state = state
    }
    
    func getState() -> State {
        return state
    }
    
    private func setupSubviews() {
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .center
        horizontalStack.distribution = .fillEqually
        horizontalStack.addArrangedSubview(playlistsButton)
        horizontalStack.addArrangedSubview(albumsButton)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(horizontalStack)
        
        let underlightStack = UIStackView()
        underlightStack.axis = .horizontal
        underlightStack.alignment = .fill
        underlightStack.distribution = .fillEqually
        underlightStack.spacing = 180
        underlightStack.addArrangedSubview(leftUnderlight)
        underlightStack.addArrangedSubview(rightUnderlight)
        underlightStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(underlightStack)
        
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            horizontalStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            horizontalStack.bottomAnchor.constraint(equalTo: underlightStack.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            underlightStack.heightAnchor.constraint(equalToConstant: 4),
            underlightStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 90),
            underlightStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -90),
            underlightStack.topAnchor.constraint(equalTo: horizontalStack.bottomAnchor),
            underlightStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    @objc private func didTapPlaylists() {
        state = .playlists
        delegate?.didTapPlaylists()
    }
    
    @objc private func didTapAlbums() {
        state = .albums
        delegate?.didTapAlbums()
    }
    
    private func toggleUnderlights() {
        leftUnderlight.backgroundColor = state == .playlists ? .label : .secondarySystemBackground
        rightUnderlight.backgroundColor = state == .albums ? .label : .secondarySystemBackground
    }
}

extension LibraryToggleView {
    enum State {
        case playlists
        case albums
    }
}
