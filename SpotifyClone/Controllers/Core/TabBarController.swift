//
//  TabBarController.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import UIKit

fileprivate enum Tab: String, CaseIterable {
    case home, search, library
}

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
    }
    
    private func setupControllers() {
        var tabs: [UINavigationController] = []
        
        for (index, tab) in Tab.allCases.enumerated() {
            let controller = tab.controller
            controller.navigationItem.largeTitleDisplayMode = .always
            let title = tab.rawValue.capitalized
            controller.title = title
            controller.tabBarItem = UITabBarItem(title: title, image: tab.image, tag: index + 1)
            
            let navController = UINavigationController(rootViewController: controller)
            navController.navigationBar.prefersLargeTitles = true
            navController.navigationBar.tintColor = .label
            tabs.append(navController)
        }
        
        setViewControllers(tabs, animated: false)
    }
}

extension Tab {
    var image: UIImage? {
        switch self {
        case .home:
            return UIImage(systemName: "house")
        case .search:
            return UIImage(systemName: "magnifyingglass")
        case .library:
            return UIImage(systemName: "music.note.list")
        }
    }
    
    var controller: UIViewController {
        switch self {
        case .home:
            return HomeViewController()
        case .search:
            return SearchViewController()
        case .library:
            return LibraryViewController()
        }
    }
}
