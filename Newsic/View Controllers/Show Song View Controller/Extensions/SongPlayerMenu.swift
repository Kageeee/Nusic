//
//  SongPlayerMenu.swift
//  Nusic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//
import Foundation
import UIKit

extension ShowSongViewController {
        
    final func setupPlayerMenu() {
        
        showMore.setImage(UIImage(named: "ShowMore")?.withRenderingMode(.alwaysTemplate), for: .normal)
        showMore.imageView?.contentMode = .scaleAspectFill
        showMore.tintColor = NusicDefaults.foregroundThemeColor
        showMore.alpha = 1
        showMore.translatesAutoresizingMaskIntoConstraints = false;
        
        previousSong.contentMode = .center
        previousSong.setImage(UIImage(named: "ThumbsDown"), for: .normal)
        previousSong.imageView?.contentMode = .scaleAspectFill
        previousSong.isHidden = true
        previousSong.translatesAutoresizingMaskIntoConstraints = false;
        previousSong.transform = CGAffineTransform(scaleX: 0.75, y: 0.75);
        
        if pausePlay.image(for: .normal) == nil {
            pausePlay.setImage(UIImage(named: "PlayTrack"), for: .normal)
        }

        pausePlay.contentMode = .center
        pausePlay.setImage(UIImage(named: "PlayTrack"), for: .normal)
        pausePlay.imageView?.contentMode = .scaleAspectFill
        pausePlay.isHidden = true
        pausePlay.transform = CGAffineTransform(scaleX: 1.25, y: 1.25);
        
        nextSong.contentMode = .center
        nextSong.setImage(UIImage(named: "ThumbsUp"), for: .normal)
        nextSong.imageView?.contentMode = .scaleAspectFill
        nextSong.isHidden = true
        nextSong.transform = CGAffineTransform(scaleX: 0.75, y: 0.75);
        
        previousTrack.setImage(UIImage(named: "Rewind"), for: .normal)
        previousTrack.imageView?.contentMode = .scaleAspectFill
        previousTrack.isHidden = true
        previousTrack.transform = CGAffineTransform(scaleX: 1.25, y: 1.25);
        
        nextTrack.setImage(UIImage(named: "FastForward"), for: .normal)
        nextTrack.imageView?.contentMode = .scaleAspectFill
        nextTrack.isHidden = true
        nextTrack.transform = CGAffineTransform(scaleX: 1.25, y: 1.25);
        
        guard preferredPlayer == NusicPreferredPlayer.spotify else { return }
        songProgressSlider.isHidden = false
        
        songProgressView.isHidden = true
        songProgressView.backgroundColor = UIColor.clear
        
        songProgressSlider.tintColor = NusicDefaults.foregroundThemeColor
        songProgressSlider.thumbTintColor = UIColor.lightGray

        songDurationLabel.textColor = UIColor.lightText
        songDurationLabel.text = songDurationLabel.text == "" ? convertElapsedSecondsToTime(interval: 0) : songDurationLabel.text
        
        songElapsedTime.textColor = UIColor.lightText
        songElapsedTime.text = songElapsedTime.text == "" ? convertElapsedSecondsToTime(interval: 0) : songElapsedTime.text
        
        self.view.layoutIfNeeded()
    }
    
    final func reloadPlayerMenu(for size: CGSize) {
        self.view.layoutIfNeeded()
    }
    
    fileprivate func openPlayerMenu() {
        self.showMore.transform = CGAffineTransform.identity;
        UIView.animate(withDuration: 0.3) {
            self.pausePlay.alpha = 1
            self.pausePlay.isHidden = false
            self.previousTrack.alpha = 1
            self.previousTrack.isHidden = false
            self.nextTrack.alpha = 1
            self.nextTrack.isHidden = false
            self.previousSong.alpha = 1
            self.previousSong.isHidden = false
            self.nextSong.alpha = 1
            self.nextSong.isHidden = false
            if self.preferredPlayer == NusicPreferredPlayer.spotify {
                self.songProgressView.isHidden = false
                self.songProgressView.alpha = 1
            }
            self.toggleLikeButtons();
            self.trackStackView.alpha = 0.9;
            self.showButtons()
            let rotateTransform = CGAffineTransform(rotationAngle: CGFloat.pi*4.5);
            self.showMore.transform = rotateTransform
            self.view.layoutIfNeeded();
            
        }
        isPlayerMenuOpen = true
    }
    
    fileprivate func closePlayerMenu(animated: Bool) {
        isPlayerMenuOpen = false
        guard animated else { hideButtons(); return }
        UIView.animate(withDuration: 0.3, animations: {
            self.previousSong.alpha = 0
            self.pausePlay.alpha = 0
            self.nextSong.alpha = 0
            self.previousTrack.alpha = 0
            self.nextTrack.alpha = 0
            
            if self.preferredPlayer == NusicPreferredPlayer.spotify {
                self.songProgressView.alpha = 0
            }
        }, completion: { (isCompleted) in
            self.previousSong.isHidden = true
            self.pausePlay.isHidden = true
            self.nextSong.isHidden = true
            self.previousTrack.isHidden = true
            self.nextTrack.isHidden = true
            if self.preferredPlayer == NusicPreferredPlayer.spotify {
                self.songProgressView.isHidden = true
            }
            
        })
        
        UIView.animate(withDuration: 0.3) {
            self.hideButtons()
            self.view.layoutIfNeeded();
        }
        self.showMore.transform = CGAffineTransform.identity;
        UIView.animate(withDuration: 0.2, animations: {
            let rotateTransform = CGAffineTransform(rotationAngle: -CGFloat.pi);
            self.showMore.transform = rotateTransform
        }, completion: nil);
    }
    
    final func togglePlayerMenu(_ animated: Bool? = true) {
        _ = isPlayerMenuOpen ? closePlayerMenu(animated: animated!) : openPlayerMenu()
    }
    
    final func hideButtons() {
        
        self.previousSong.isHidden = true
        self.pausePlay.isHidden = true
        self.nextSong.isHidden = true
        self.previousTrack.isHidden = true
        self.nextTrack.isHidden = true
        if self.preferredPlayer == NusicPreferredPlayer.spotify {
            self.songProgressView.isHidden = true
        }
        
        self.pausePlayTopConstraint.constant -= self.view.frame.height * 0.20
        self.previousTrackCenterXConstraint.constant -= -self.trackStackView.bounds.width/4
        self.previousTrackTopConstraint.constant -= self.view.frame.height * 0.20
        self.nextTrackCenterXConstraint.constant -= self.trackStackView.bounds.width/4
        self.nextTrackTopConstraint.constant -= self.view.frame.height * 0.20
        self.dislikeSongCenterXConstraint.constant -= -self.trackStackView.bounds.width/2
        self.dislikeSongTopConstraint.constant -= self.view.frame.height * 0.20
        self.likeSongCenterXConstraint.constant -= self.trackStackView.bounds.width/2
        self.likeSongTopConstraint.constant -= self.view.frame.height * 0.20
        self.songProgressBottomConstraint.constant -= self.view.frame.height * 0.10
        self.songProgressTopConstraint.constant -= self.view.frame.height * 0.10
        self.songCardBottomConstraint.constant -= self.view.frame.height * 0.20
        self.showMoreBottomConstraint.constant -= self.view.frame.height * 0.15
        self.view.layoutIfNeeded();
    }
    
    final func showButtons() {
        self.songProgressBottomConstraint.constant += self.view.frame.height * 0.10
        self.songProgressTopConstraint.constant += self.view.frame.height * 0.10
        self.songCardBottomConstraint.constant += self.view.frame.height * 0.20
        self.showMoreBottomConstraint.constant += self.view.frame.height * 0.15
        self.pausePlayTopConstraint.constant += self.view.frame.height * 0.20
        self.previousTrackCenterXConstraint.constant += -self.trackStackView.bounds.width/4
        self.previousTrackTopConstraint.constant += self.view.frame.height * 0.20
        self.nextTrackCenterXConstraint.constant += self.trackStackView.bounds.width/4
        self.nextTrackTopConstraint.constant += self.view.frame.height * 0.20
        self.dislikeSongCenterXConstraint.constant += -self.trackStackView.bounds.width/2
        self.dislikeSongTopConstraint.constant += self.view.frame.height * 0.20
        self.likeSongCenterXConstraint.constant += self.trackStackView.bounds.width/2
        self.likeSongTopConstraint.constant += self.view.frame.height * 0.20
    }
    
    final func toggleLikeButtons() {
        _ = !self.isSongLiked ? showLikeButtons() : hideLikeButtons()
    }
    
    final func showLikeButtons() {
        DispatchQueue.main.async {
            self.previousSong.alpha = 1
            self.previousSong.isUserInteractionEnabled = true
            self.nextSong.alpha = 1
            self.nextSong.isUserInteractionEnabled = true
        }
        
    }
    
    final func hideLikeButtons() {
        DispatchQueue.main.async {
            self.previousSong.alpha = 0.25
            self.previousSong.isUserInteractionEnabled = false
            self.nextSong.alpha = 0.25
            self.nextSong.isUserInteractionEnabled = false
        }
    }
    
    final func setupSongProgress(duration: Float) {
        let currentDuration = Int(duration)
        setupSlider(duration: duration)
        updateElapsedTime(elapsedTime: 0, duration: duration)
        songDurationLabel.text = convertElapsedSecondsToTime(interval: currentDuration);
    }
    
    final func updateElapsedTime(elapsedTime: Float, duration: Float ) {
        songElapsedTime.text = convertElapsedSecondsToTime(interval: Int(elapsedTime))
        let durationLeft = convertElapsedSecondsToTime(interval: Int(elapsedTime-duration))
        songDurationLabel.text = !durationLeft.contains("-") ? "-\(durationLeft)" : durationLeft
    }
    
    final func setupSlider(duration: Float) {
        songProgressSlider.maximumValue = duration
        songProgressSlider.minimumValue = 0
        songProgressSlider.setValue(0, animated: true)
    }
    
}



