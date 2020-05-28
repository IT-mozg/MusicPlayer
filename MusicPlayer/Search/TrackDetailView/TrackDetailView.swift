//
//  TrackDetailView.swift
//  MusicPlayer
//
//  Created by Vlad Tkachuk on 26.05.2020.
//  Copyright © 2020 Vlad Tkachuk. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import AVKit

protocol TrackSwitchDelegate {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell?
    func moveForwardForPreviousTrack() -> SearchViewModel.Cell?
}

protocol TrackDetailViewTransitionDelegate: class {
    func minimizeTrackDetailController()
    func maximizeTrackDetailController(viewModel: SearchViewModel.Cell?)
}

class TrackDetailView: UIView {
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var currentTimeSilder: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var authorTitleLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var miniTrackDetailView: UIView!
    @IBOutlet weak var miniGoForwardButton: UIButton!
    @IBOutlet weak var maximizedStackView: UIStackView!
    @IBOutlet weak var miniTrackImageView: UIImageView!
    @IBOutlet weak var miniTrackTitleLabel: UILabel!
    @IBOutlet weak var miniPlayPauseButton: UIButton!
    
    var switchDelegate: TrackSwitchDelegate?
    weak var transitionDelegate: TrackDetailViewTransitionDelegate?
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let scale: CGFloat = 0.8
        self.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        self.trackImageView.layer.cornerRadius = 5
        self.miniPlayPauseButton.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        self.setupGestures()
    }
    
    // MARK: Setup
    
    func set(viewModel: SearchViewModel.Cell) {
        self.miniTrackTitleLabel.text = viewModel.trackName
        self.trackTitleLabel.text = viewModel.trackName
        self.authorTitleLabel.text = viewModel.artistName
        self.playTrack(previewUrl: viewModel.previewUrl)
        self.monitorStartTime()
        self.observePlayerCurrentTime()
        self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        let string600 = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600")
        guard let url = URL(string: string600 ?? "") else { return }
        self.trackImageView.sd_setImage(with: url, completed: nil)
        self.miniTrackImageView.sd_setImage(with: url, completed: nil)
    }
    
    private func setupGestures() {
        self.miniTrackDetailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximized)))
        self.miniTrackDetailView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
    }
    
    
    
    private func playTrack(previewUrl: String?) {
        guard let url = URL(string: previewUrl ?? "") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    // MARK: Maximizing and minimizing gestures
    
    @objc private func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self.superview)
            maximizedStackView.transform = .init(translationX: 0, y: translation.y)
        case .ended:
            let translation = gesture.translation(in: self.superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.maximizedStackView.transform = .identity
                if translation.y > 50 {
                    self.transitionDelegate?.minimizeTrackDetailController()
                }
            })
            
            
            
        default: break
        }
    }
    
    @objc private func handleTapMaximized() {
        self.transitionDelegate?.maximizeTrackDetailController(viewModel: nil)
    }
    
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            break
        case .changed:
            self.handlePanChange(gesture: gesture)
        case .ended:
            self.handlePanEnded(gesture: gesture)
        default: break
        }
    }
    
    private func handlePanChange(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        let newAlpha = 1 + translation.y / 200
        self.miniTrackDetailView.alpha = newAlpha < 0 ? 0 : newAlpha
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    private func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity
            if translation.y < -200 || velocity.y < -500 {
                self.transitionDelegate?.maximizeTrackDetailController(viewModel: nil)
            } else {
                self.miniTrackDetailView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        })
    }
    
    // MARK: Time setup
    private func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {[weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            let durationTime = self?.player.currentItem?.duration
            let currentDurationString = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            self?.durationLabel.text = "-\(currentDurationString)"
            self?.updateCurrentTimeSlider()
        }
    }
    
    private func monitorStartTime() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeTrackImageView()
        }
    }
    
    private func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds/durationSeconds
        self.currentTimeSilder.value = Float(percentage)
    }
    
    // MARK: Animations
    private func enlargeTrackImageView() {
        UIView.animate(withDuration: 1, delay: 0,usingSpringWithDamping: 0.5,initialSpringVelocity: 1,options: .curveEaseOut,animations: { [weak self] in
            self?.trackImageView.transform = .identity
        })
    }
    
    private func reduceTrackImageView() {
        UIView.animate(withDuration: 1, delay: 0,usingSpringWithDamping: 0.5,initialSpringVelocity: 1,options: .curveEaseOut,animations: { [weak self] in
            let scale: CGFloat = 0.8
            self?.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
    }
    
    // MARK: IBActions
    
    @IBAction func dragDownButtonTapped(_ sender: Any) {
        self.transitionDelegate?.minimizeTrackDetailController()
        //        self.removeFromSuperview()
    }
    
    @IBAction func handleCurrentTimerSlider(_ sender: Any) {
        let percentage = currentTimeSilder.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeUnSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeUnSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeSlider(_ sender: Any) {
        player.volume = volumeSlider.value
    }
    
    @IBAction func previosTrack(_ sender: Any) {
        guard let cellViewModel = switchDelegate?.moveBackForPreviousTrack() else { return }
        self.set(viewModel: cellViewModel)
    }
    
    @IBAction func nextTrack(_ sender: Any) {
        guard let cellViewModel = switchDelegate?.moveForwardForPreviousTrack() else { return }
        self.set(viewModel: cellViewModel)
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        if self.player.timeControlStatus == .paused {
            self.player.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.enlargeTrackImageView()
        } else {
            self.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.reduceTrackImageView()
        }
    }
}
