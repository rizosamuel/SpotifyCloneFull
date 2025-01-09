//
//  TrackCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 09/12/24.
//

import UIKit

class TrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackCollectionViewCell"
    
    private let trackCover: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let trackLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.sizeToFit()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGray6
        contentView.addSubview(trackCover)
        contentView.addSubview(trackLabel)
        contentView.addSubview(artistLabel)
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        constrainTrackCover()
        constrainTrackLabel()
        constrainArtistLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func constrainTrackCover() {
        NSLayoutConstraint.activate([
            trackCover.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackCover.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackCover.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            trackCover.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -300)
        ])
    }
    
    private func constrainTrackLabel() {
        NSLayoutConstraint.activate([
            trackLabel.leadingAnchor.constraint(equalTo: trackCover.trailingAnchor, constant: 10),
            trackLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            trackLabel.topAnchor.constraint(equalTo: trackCover.topAnchor, constant: 10)
        ])
    }
    
    private func constrainArtistLabel() {
        NSLayoutConstraint.activate([
            artistLabel.leadingAnchor.constraint(equalTo: trackCover.trailingAnchor, constant: 10),
            artistLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            artistLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            artistLabel.topAnchor.constraint(equalTo: trackLabel.bottomAnchor, constant: 10)
        ])
    }
    
    func configure(with viewModel: TracksCellViewModel, needsArtwork: Bool = true) {
        trackLabel.text = viewModel.name
        artistLabel.text = viewModel.artistName
        
        if needsArtwork {
            trackCover.sd_setImage(with: viewModel.artworkUrl, completed: nil)
        } else {
            trackCover.trailingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackLabel.text = nil
        artistLabel.text = nil
        trackCover.image = nil
    }
}
