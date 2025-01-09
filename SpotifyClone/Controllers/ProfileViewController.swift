//
//  ProfileViewController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    struct Constants {
        static let PROFILE_IMG_DEFAULT = "https://media2.dev.to/dynamic/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/http%3A%2F%2Fplacekitten.com%2F250%2F250"
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var models: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .systemBackground
        
        tableView.frame = view.bounds
        tableView.center = view.center
        tableView.isHidden = true
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchProfile()
    }
    
    private func fetchProfile() {
        APIManager.shared.getCurrentUserProfile { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let model):
                    self?.updateUI(with: model)
                case .failure(let error):
                    print("Error", error)
                    self?.failedToGetProfile()
                }
            }
        }
    }
    
    private func updateUI(with model: UserProfile) {
        tableView.isHidden = false
        models.append("Full Name \(model.displayName)")
        models.append("Email Address \(model.email)")
        models.append("User ID \(model.id)")
        models.append("Plan \(model.product)")
        let urlString = model.images.first?.url ?? Constants.PROFILE_IMG_DEFAULT
        createTableHeader(with: urlString)
        tableView.reloadData()
    }
    
    private func createTableHeader(with urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else {
            return
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width / 1.5))
        let imageSize: CGFloat = headerView.height / 2
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        headerView.addSubview(imageView)
        imageView.center = headerView.center
        imageView.contentMode = .scaleAspectFill
        imageView.sd_setImage(with: url, completed: nil)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize / 2
        imageView.layer.borderWidth = 2
        
        tableView.tableHeaderView = headerView
    }
    
    private func failedToGetProfile() {
        let label = UILabel(frame: .zero)
        label.text = "Failed to load Profile"
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = models[indexPath.row]
        cell.selectionStyle = .none
        cell.contentConfiguration = contentConfig
        return cell
    }
}
