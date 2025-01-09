//
//  PlaylistHeaderCollectionReusableView.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 11/12/24.
//

import UIKit
import SDWebImage

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject {
    func didTapPlayAll(_ header: PlaylistHeaderCollectionReusableView)
}

class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PlaylistHeaderCollectionReusableView"
    
    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .ultraLight)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let playlistArtwork: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(systemName: "music.note.list")
        imageView.backgroundColor = .label
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return imageView
    }()
    
    private let playAllButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGreen
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .systemBackground
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.shadowRadius = 5
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(playlistArtwork)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(ownerLabel)
        addSubview(playAllButton)
        
        constrainPlaylistArtwork()
        constrainNameLabel()
        constrainOwnerLabel()
        constrainDescriptionLabel()
        constrainPlayAllButton()
        playAllButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func constrainPlaylistArtwork() {
        NSLayoutConstraint.activate([
            playlistArtwork.centerXAnchor.constraint(equalTo: centerXAnchor),
            playlistArtwork.widthAnchor.constraint(equalTo: playlistArtwork.heightAnchor, multiplier: 1),
            playlistArtwork.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            playlistArtwork.heightAnchor.constraint(greaterThanOrEqualToConstant: 300)
        ])
    }
    
    private func constrainNameLabel() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: playlistArtwork.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: playAllButton.leadingAnchor, constant: -10)
        ])
    }
    
    private func constrainOwnerLabel() {
        NSLayoutConstraint.activate([
            ownerLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0),
            ownerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            ownerLabel.trailingAnchor.constraint(equalTo: playAllButton.leadingAnchor, constant: -10)
        ])
    }
    
    private func constrainDescriptionLabel() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: ownerLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: playAllButton.leadingAnchor, constant: -10),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50)
        ])
    }
    
    private func constrainPlayAllButton() {
        NSLayoutConstraint.activate([
            playAllButton.topAnchor.constraint(equalTo: playlistArtwork.bottomAnchor, constant: -20),
            playAllButton.widthAnchor.constraint(equalToConstant: 60),
            playAllButton.heightAnchor.constraint(equalTo: playAllButton.widthAnchor, multiplier: 1),
            playAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    func configure(with viewModel: PlaylistHeaderCollectionReusableViewModel) {
        nameLabel.text = viewModel.name
        ownerLabel.text = viewModel.owner
        descriptionLabel.text = viewModel.description
        playAllButton.backgroundColor = viewModel.isActive ? .systemGreen : .systemGray
        playAllButton.isUserInteractionEnabled = viewModel.isActive
        if viewModel.artworkUrl != nil {
            playlistArtwork.sd_setImage(with: viewModel.artworkUrl)
        }
    }
    
    @objc private func didTapPlayAll() {
        delegate?.didTapPlayAll(self)
    }
}
