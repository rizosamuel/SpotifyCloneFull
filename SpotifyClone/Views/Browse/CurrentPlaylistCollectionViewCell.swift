//
//  CurrentPlaylistCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 10/12/24.
//

import UIKit

class CurrentPlaylistCollectionViewCell: UICollectionViewCell {
    static let identifier = "CurrentPlaylistCollectionViewCell"
    
    private let playlistCover: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "music.note.list")
        imageView.backgroundColor = .label
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let playlistLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        label.textColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.sizeToFit()
        label.textColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.addSubview(playlistCover)
        contentView.addSubview(playlistLabel)
        contentView.addSubview(ownerLabel)
        constrainOwnerLabel()
        constrainCategoryLabel()
        constrainPlaylistCover()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func constrainOwnerLabel() {
        NSLayoutConstraint.activate([
            ownerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            ownerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            ownerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            ownerLabel.topAnchor.constraint(equalTo: playlistLabel.bottomAnchor, constant: 10)
        ])
    }
    
    private func constrainCategoryLabel() {
        NSLayoutConstraint.activate([
            playlistLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            playlistLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            playlistLabel.bottomAnchor.constraint(equalTo: ownerLabel.topAnchor)
        ])
    }
    
    private func constrainPlaylistCover() {
        NSLayoutConstraint.activate([
            playlistCover.topAnchor.constraint(equalTo: contentView.topAnchor),
            playlistCover.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playlistCover.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            playlistCover.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with viewModel: CurrentPlaylistsCellViewModel) {
        playlistLabel.text = viewModel.name
        ownerLabel.text = viewModel.ownerName
        if viewModel.artworkUrl != nil {
            playlistCover.sd_setImage(with: viewModel.artworkUrl, completed: nil)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistLabel.text = nil
        ownerLabel.text = nil
        playlistCover.image = nil
    }
}
