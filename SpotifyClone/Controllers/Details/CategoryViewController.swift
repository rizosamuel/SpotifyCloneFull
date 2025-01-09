//
//  CategoryViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 10/12/24.
//

import UIKit
import SDWebImage

class CategoryViewController: UIViewController {
    
    private let category: Category
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    init(category: Category) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        title = category.name
        view.addSubview(imageView)
        fetchData()
        constrainImageView()
    }
    
    private func constrainImageView() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50)
        ])
    }
    
    private func fetchData() {
        APIManager.shared.getCategoryDetails(for: category) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let category):
                    if let url = category.icons.first?.url {
                        self?.imageView.sd_setImage(with: URL(string: url))
                    }
                case .failure(let error):
                    guard let self else { return }
                    let label = UILabel(frame: .zero)
                    label.text = error.localizedDescription
                    label.textColor = .systemGray
                    label.sizeToFit()
                    self.view.addSubview(label)
                    label.center = self.view.center
                }
            }
        }
    }
}
