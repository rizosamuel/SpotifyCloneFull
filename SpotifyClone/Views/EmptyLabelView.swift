//
//  EmptyLabelView.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 30/12/24.
//

import UIKit

class EmptyLabelView: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String) {
        self.text = text
        textAlignment = .center
        textColor = .systemGray
        sizeToFit()
    }
}

extension EmptyLabelView {
    func centerContrainTo(view: UIView, centerX: CGFloat = 0, centerY: CGFloat = 0, width: CGFloat = 20) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: centerX),
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: centerY),
            self.widthAnchor.constraint(equalTo: view.widthAnchor, constant: width)
        ])
    }
}
