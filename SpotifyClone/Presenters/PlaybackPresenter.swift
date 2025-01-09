//
//  PlaybackPresenter.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 19/12/24.
//

import UIKit
import AVFoundation
import Combine

protocol PlayerDataSource: AnyObject {
    var songName: String? { get set }
    var subtitle: String? { get set }
    var imageUrl: URL? { get set }
    var uri: String? { get set }
    var didChange: (() -> Void)? { get set }
}

class PlaybackPresenter: NSObject, PlayerDataSource {
    
    static let shared = PlaybackPresenter()
    
    private var player: AVPlayer?
    private var currentTracks: [PlaybackPresenterViewModel] = []
    private var currentTrackIndex = 0
    
    var songName: String?
    var subtitle: String?
    var imageUrl: URL?
    var uri: String?
    var didChange: (() -> Void)?
    
    private override init() { }
    
    func startPlayback(from parent: UIViewController, viewModel: PlaybackPresenterViewModel) {
        currentTracks = []
        songName = viewModel.name
        subtitle = viewModel.subtitle
        imageUrl = viewModel.url
        uri = viewModel.uri
        configurePlayer(with: parent)
    }
    
    func startPlayback(from parent: UIViewController, viewModels: [PlaybackPresenterViewModel]) {
        currentTracks = viewModels
        currentTrackIndex = 0
        updateCurrentTrack()
        configurePlayer(with: parent)
    }
    
    private func updateCurrentTrack() {
        songName = currentTracks[currentTrackIndex].name
        subtitle = currentTracks[currentTrackIndex].subtitle
        imageUrl = currentTracks[currentTrackIndex].url
        uri = currentTracks[currentTrackIndex].uri
        didChange?()
        
        player = getAVPlayer()
        player?.play()
    }
    
    private func configurePlayer(with parent: UIViewController) {
        let playerVC = PlayerViewController()
        let navVC = UINavigationController(rootViewController: playerVC)
        playerVC.dataSource = self
        playerVC.delegate = self
        
        player = getAVPlayer()
        
        parent.present(navVC, animated: true) { [weak self] in
            self?.player?.play()
        }
    }
    
    private func getAVPlayer() -> AVPlayer {
        let songUrl = URL(string: "https://open.spotify.com/track/11dFghVXANMlKmJXsNCbNl?si=72b2956ccb8c44b9")!
        
        let player = AVPlayer(url: songUrl)
        player.volume = 0.5
        return player
    }
}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    
    func didTapPlayPause() {
        guard let player else { return }
        
        switch player.timeControlStatus {
        case .paused: player.play()
        case .playing: player.pause()
        default: break
        }
    }
    
    func didTapForwards() {
        guard let player else { return }
        
        if currentTracks.isEmpty {
            player.pause()
        } else {
            currentTrackIndex = (currentTrackIndex < (currentTracks.count - 1)) ? currentTrackIndex + 1 : 0
            updateCurrentTrack()
        }
    }
    
    func didTapBackwards() {
        guard let player else { return }
        
        if currentTracks.isEmpty {
            player.pause()
            player.play()
        } else {
            currentTrackIndex = currentTrackIndex > 0 ? currentTrackIndex - 1 : currentTracks.count - 1
            updateCurrentTrack()
        }
    }
    
    func didChangeVolume(with value: Float) {
        player?.volume = value
    }
}
