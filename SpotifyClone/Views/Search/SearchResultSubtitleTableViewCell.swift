//
//  SearchResultSubtitleTableViewCell.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 19/12/24.
//

import UIKit
import SDWebImage

class SearchResultSubtitleTableViewCell: UITableViewCell {
    static let identifier = "SearchResultSubtitleTableViewCell"
    
    private let primaryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.numberOfLines = 1
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .label
        imageView.image = UIImage(systemName: "music.note.list")
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(primaryLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(iconImageView)
        accessoryType = .disclosureIndicator
        constrainPrimaryLabel()
        constrainSubtitleLabel()
        constrainIconImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func constrainPrimaryLabel() {
        NSLayoutConstraint.activate([
            primaryLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 5),
            primaryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            primaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    private func constrainSubtitleLabel() {
        NSLayoutConstraint.activate([
            subtitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 5),
            subtitleLabel.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor, constant: 5),
            primaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    private func constrainIconImageView() {
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2)
        ])
    }
    
    func configure(with viewModel: SearchResultSubtitleTableViewCellViewModel) {
        primaryLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        if viewModel.imageURL != nil {
            iconImageView.sd_setImage(with: viewModel.imageURL)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        primaryLabel.text = nil
        subtitleLabel.text = nil
        iconImageView.image = nil
    }
}
