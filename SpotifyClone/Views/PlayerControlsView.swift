//
//  PlayerControlsView.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 19/12/24.
//

import UIKit

protocol PlayerControlsViewDelegate: AnyObject {
    func didTapPlayPause()
    func didTapForwards()
    func didTapBackwards()
    func didSlideVolume(with value: Float)
}

struct PlayerControlsViewModel {
    let title: String?
    let subtitle: String?
}

class PlayerControlsView: UIView {
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.value = 0.5
        return slider
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "There"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let config = UIImage.SymbolConfiguration(pointSize: 34, weight: .ultraLight)
        let image = UIImage(systemName: "backward.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let playImage: UIImage? = {
        let config = UIImage.SymbolConfiguration(pointSize: 34, weight: .ultraLight)
        let image = UIImage(systemName: "play.fill", withConfiguration: config)
        return image
    }()
    
    private let pauseImage: UIImage? = {
        let config = UIImage.SymbolConfiguration(pointSize: 34, weight: .regular)
        let image = UIImage(systemName: "pause.fill", withConfiguration: config)
        return image
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let config = UIImage.SymbolConfiguration(pointSize: 34, weight: .regular)
        let image = UIImage(systemName: "pause.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let config = UIImage.SymbolConfiguration(pointSize: 34, weight: .ultraLight)
        let image = UIImage(systemName: "forward.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        return button
    }()
    
    weak var delegate: PlayerControlsViewDelegate?
    private var isPlaying = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        clipsToBounds = true
        
        constrainViews()
        
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        volumeSlider.addTarget(self, action: #selector(didChangeVolume), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func constrainViews() {
        let verticalStack = UIStackView()
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.axis = .vertical
        verticalStack.alignment = .fill
        verticalStack.spacing = 10
        verticalStack.addArrangedSubview(nameLabel)
        verticalStack.addArrangedSubview(subtitleLabel)
        verticalStack.addArrangedSubview(volumeSlider)
        
        let horizontalStack = UIStackView()
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .center
        horizontalStack.distribution = .equalSpacing
        horizontalStack.spacing = 10
        horizontalStack.addArrangedSubview(backButton)
        horizontalStack.addArrangedSubview(playPauseButton)
        horizontalStack.addArrangedSubview(nextButton)
        
        addSubview(verticalStack)
        addSubview(horizontalStack)
        
        NSLayoutConstraint.activate([
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            verticalStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            horizontalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            horizontalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            horizontalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            horizontalStack.topAnchor.constraint(equalTo: verticalStack.bottomAnchor, constant: 50)
        ])
    }
    
    func configure(with viewModel: PlayerControlsViewModel) {
        nameLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
    
    @objc private func didTapPlayPause() {
        delegate?.didTapPlayPause()
        isPlaying = !isPlaying
        playPauseButton.setImage(isPlaying ? pauseImage : playImage, for: .normal)
    }
    
    @objc private func didTapBack() {
        delegate?.didTapBackwards()
    }
    
    @objc private func didTapNext() {
        delegate?.didTapForwards()
    }
    
    @objc private func didChangeVolume(_ slider: UISlider) {
        delegate?.didSlideVolume(with: slider.value)
    }
}
