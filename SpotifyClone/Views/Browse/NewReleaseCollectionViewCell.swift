//
//  Untitled.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 09/12/24.
//

import UIKit
import SDWebImage

class NewReleaseCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewReleaseCollectionViewCell"
    
    private let albumCover: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let albumLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return label
    }()
    
    private let numOfTracksLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.addSubview(albumCover)
        contentView.addSubview(albumLabel)
        contentView.addSubview(numOfTracksLabel)
        contentView.addSubview(artistLabel)
        constrainAlbumCover()
        constrainAlbumLabel()
        constrainTracksLabel()
        constrainArtistLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func constrainAlbumCover() {
        NSLayoutConstraint.activate([
            albumCover.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            albumCover.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            albumCover.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            albumCover.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -220)
        ])
    }
    
    private func constrainAlbumLabel() {
        NSLayoutConstraint.activate([
            albumLabel.leadingAnchor.constraint(equalTo: albumCover.trailingAnchor, constant: 10),
            albumLabel.topAnchor.constraint(equalTo: albumCover.topAnchor, constant: 10),
            albumLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    private func constrainArtistLabel() {
        let bottomConstraint = artistLabel.bottomAnchor.constraint(equalTo: numOfTracksLabel.topAnchor, constant: 10)
        bottomConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            artistLabel.leadingAnchor.constraint(equalTo: albumCover.trailingAnchor, constant: 10),
            artistLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            artistLabel.topAnchor.constraint(equalTo: albumLabel.bottomAnchor, constant: 10),
            bottomConstraint
        ])
    }
    
    private func constrainTracksLabel() {
        NSLayoutConstraint.activate([
            numOfTracksLabel.leadingAnchor.constraint(equalTo: albumCover.trailingAnchor, constant: 10),
            numOfTracksLabel.bottomAnchor.constraint(equalTo: albumCover.bottomAnchor, constant: -10),
            numOfTracksLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func configure(with viewModel: NewReleasesCellViewModel) {
        albumLabel.text = viewModel.name
        artistLabel.text = viewModel.artistName
        numOfTracksLabel.text = "Tracks: \(viewModel.numberOfTracks)"
        albumCover.sd_setImage(with: viewModel.artworkUrl, completed: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumLabel.text = nil
        artistLabel.text = nil
        numOfTracksLabel.text = nil
        albumCover.image = nil
    }
}
