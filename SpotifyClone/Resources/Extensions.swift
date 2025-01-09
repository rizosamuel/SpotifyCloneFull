//
//  Extensions.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import UIKit

extension UIView {
    var width: CGFloat {
        return frame.size.width
    }
    
    var height: CGFloat {
        return frame.size.height
    }
    
    var left: CGFloat {
        return frame.origin.x
    }
    
    var right: CGFloat {
        left + width
    }
    
    var top: CGFloat {
        return frame.origin.y
    }
    
    var bottom: CGFloat {
        return top + height
    }
}

extension String {
    var toFormattedDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateFormatter.dateStyle = .medium
        let date = dateFormatter.date(from: self) ?? Date()
        return dateFormatter.string(from: date)
    }
}

protocol FileIdentifier {
    var fileName: String { get }
}

extension FileIdentifier {
    var fileName: String {
        String(describing: type(of: self))
    }
}

extension UIViewController {
    func showSimpleAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    func resetRootViewController(to vc: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            window.rootViewController = vc
        }
    }
}
