//
//  CategoryCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 09/12/24.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell"
    
    private let categoryCover: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let categoryLabel: UILabel = {
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
    
    private let hashtagLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.sizeToFit()
        label.textColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.addSubview(categoryCover)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(hashtagLabel)
        constrainHashtagLabel()
        constrainCategoryLabel()
        constrainCategoryCover()    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func constrainHashtagLabel() {
        NSLayoutConstraint.activate([
            hashtagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            hashtagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            hashtagLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 0),
            hashtagLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    private func constrainCategoryLabel() {
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    private func constrainCategoryCover() {
        NSLayoutConstraint.activate([
            categoryCover.topAnchor.constraint(equalTo: contentView.topAnchor),
            categoryCover.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryCover.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryCover.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with viewModel: CategoriesCellViewModel) {
        categoryLabel.text = viewModel.name
        hashtagLabel.text = viewModel.hashtag
        categoryCover.sd_setImage(with: viewModel.artworkUrl, completed: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryLabel.text = nil
        hashtagLabel.text = nil
        categoryCover.image = nil
    }
}
