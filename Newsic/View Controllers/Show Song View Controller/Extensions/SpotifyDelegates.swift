//
//  SpotifyDelegates.swift
//  Newsic
//
//  Created by Miguel Alcantara on 31/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import MediaPlayer


extension ShowSongViewController: SPTAudioStreamingDelegate {
    
    func setupStreamingDelegate() {
        player?.delegate = self;
    }
    
    func resetStreamingDelegate() {
        player?.delegate = nil
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        //print("position changed");
        let currentTrack = audioStreaming.metadata.currentTrack;
        if let currentTrack = currentTrack, let currentPlayingTrack = currentPlayingTrack {
            let currentPosition = Float(position)
            //MPNowPlayingInfoCenter.default().nowPlayingInfo?.updateValue(position, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime);
            songProgressSlider.value = currentPosition
            updateElapsedTime(elapsedTime: currentPosition)
//            self.updateNowPlayingCenter(title: currentTrack.name, artist: currentTrack.artistName, currentTime: currentPosition as NSNumber, songLength: currentTrack.duration as NSNumber, playbackRate: 1)
            self.updateNowPlayingCenter(title: currentPlayingTrack.songName, artist: currentPlayingTrack.artist.artistName, albumArt: currentPlayingTrack.thumbNail as AnyObject, currentTime: currentPosition as NSNumber, songLength: currentTrack.duration as NSNumber, playbackRate: 1)
//            var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo;
            //nowPlayingInfo?.updateValue(position, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
            //nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = position
            //nowPlayingInfo.updateValue(position, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime);
            //songElapsedTime.text = "\(position.rounded())"
        }
        
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didSeekToPosition position: TimeInterval) {
        
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        
        // WORKAROUND : Reload data to correctly show Album Images in Table View. Otherwise, they're downloaded but not correctly loaded in the image view.
        self.songListTableView.reloadData()
        let currentTrack = audioStreaming.metadata.currentTrack;
        
        print("track started");
        if let currentTrack = currentTrack {
            if let imageURL = currentTrack.albumCoverArtURL {
                let imageURL = URL(string: imageURL)!
                let image = UIImage(); image.downloadImage(from: imageURL) { (image) in
                    let songTitle = "\(currentTrack.artistName) - \(currentTrack.name)"
                    let currentPlayingTrack = SpotifyTrack(title: songTitle, thumbNail: image, trackUri: currentTrack.uri, trackId: Spotify.transformToID(trackUri: currentTrack.uri), songName: currentTrack.name ,artist: SpotifyArtist(artistName: currentTrack.artistName, subGenres: nil, popularity: nil, uri: currentTrack.artistUri), audioFeatures: nil)
                    self.currentPlayingTrack = currentPlayingTrack;
                    self.activateAudioSession()
                    self.updateNowPlayingCenter(title: currentPlayingTrack.songName, artist: currentPlayingTrack.artist.artistName, albumArt: image as AnyObject, currentTime: 0, songLength: currentTrack.duration as NSNumber, playbackRate: 1)
                    DispatchQueue.main.async {
                        self.toggleLikeButtons()
                    }
                    
//                    self.updateNowPlayingCenter(title: currentTrack.name, artist: currentTrack.artistName, albumArt: image, currentTime: 0, songLength: currentTrack.duration as NSNumber, playbackRate: 1)
                    
                }
            } else {
                activateAudioSession()
                updateNowPlayingCenter(title: currentTrack.name, artist: currentTrack.artistName, albumArt: nil, currentTime: 0, songLength: currentTrack.duration as NSNumber, playbackRate: 1)
            }
            setupSongProgress(duration: Float(currentTrack.duration))
        } else {
            print("problem starting track");
        }
        
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
//        deactivateAudioSession();
        
        DispatchQueue.main.async {
            self.hideLikeButtons()
        }
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        if let nowPlayingInfo = nowPlayingInfo, let currentTrack = audioStreaming.metadata.currentTrack {
            let elapsedTime = nowPlayingInfo["playbackDuration"] as? Double
            let duration = Double(currentTrack.duration)
            if elapsedTime != nil && elapsedTime == duration {
                songCardView.swipe(.left);
            }
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
//        print("logged in")
        //actionPlaySpotifyTrack(spotifyTrackId: "58s6EuEYJdlb0kO7awm3Vp");
        
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceive event: SpPlaybackEvent) {
        //print("RECEIVED EVENT")
        
    }
    
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if isPlaying {
            self.activateAudioSession()
        } else {
            self.deactivateAudioSession()
        }
    }
    
    
}

extension ShowSongViewController: SPTAudioStreamingPlaybackDelegate {
    func setupPlaybackDelegate() {
        player?.playbackDelegate = self
    }
    
    func resetPlaybackDelegate() {
        player?.playbackDelegate = nil
    }
}


extension ShowSongViewController {
    
    func setupSpotify() {
        auth = SPTAuth.defaultInstance();
        player = SPTAudioStreamingController.sharedInstance();
        
        setupStreamingDelegate();
        setupPlaybackDelegate();
        
        if !(self.player?.initialized)! {
            do {
                try self.player?.start(withClientId: self.auth.clientID);
            } catch { print("error starting") }
        }
        self.player?.login(withAccessToken: self.auth.session.accessToken);
        
    }
    
    func convertElapsedSecondsToTime(interval: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        
        let formattedString = formatter.string(from: TimeInterval(interval))!
        //print(formattedString)
        return formattedString
    }
    
    func togglePausePlayIcon() {
        if isPlaying {
            pausePlay.setImage(UIImage(named: "PauseTrack"), for: .normal)
        } else {
            pausePlay.setImage(UIImage(named: "PlayTrack"), for: .normal)
        }
    }
    
    func spotifyPausePlay() {
        
        
        self.isPlaying = !self.isPlaying;
        
        if self.isPlaying {
            if currentPlayingTrack == nil {
                actionPlaySpotifyTrack(spotifyTrackId: cardList[songCardView.currentCardIndex].trackInfo.trackUri)
            }
        }
        player?.setIsPlaying(isPlaying, callback: { (error) in
            
            self.togglePausePlayIcon()
//            var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
//            nowPlayingInfo?.updateValue(self.player?.playbackState.position, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
            if error != nil {
                print("ERROR PAUSING TRACK");
            }
        })
        
        
    }
    
    @objc func actionPreviousSong() {
        songCardView.revertAction()
//        player?.skipPrevious({ (error) in
//            if error != nil {
//                print("ERROR SET PREVIOUS TRACK");
//            }
//        })
    }
    
    @objc func actionNextSong() {
        songCardView.swipe(.left)
//        player?.skipNext({ (error) in
//            if error != nil {
//                print("ERROR SET NEXT TRACK");
//            }
//        })
    }
    
    @objc func seekSong(interval: Float) {
        player?.seek(to: TimeInterval(interval), callback: { (error) in
            if let error = error {
                print("Error seeking track! error: \(error.localizedDescription)")
            }
        })
    }
    
    @objc func remoteControlSeekSong(event: MPRemoteCommandEvent) {
        if event is MPChangePlaybackPositionCommandEvent {
            let command = event as! MPChangePlaybackPositionCommandEvent
            seekSong(interval: Float(command.positionTime))
        }
    }
    
    @objc func remoteControlPlaySong(event: MPRemoteCommandEvent) {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        
        if var nowPlayingInfo = nowPlayingInfo {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.playbackState.position
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            spotifyPausePlay()
        }
    }
    
    @objc func remoteControlPauseSong(event: MPRemoteCommandEvent) {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        
        if var nowPlayingInfo = nowPlayingInfo {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
            //nowPlayingInfo.updateValue(0, forKey: MPNowPlayingInfoPropertyPlaybackRate);
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.playbackState.position
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            spotifyPausePlay()
        }
    }
    
    @objc func actionPlaySpotifyTrack(spotifyTrackId: String) {
        self.isPlaying = false
        self.activateAudioSession()
//        print("Trying to play track \(spotifyTrackId)")
        player?.playSpotifyURI(spotifyTrackId, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            self.isPlaying = true;
            self.togglePausePlayIcon()
            if (error != nil) {
                print("error playing!, error : \(String(describing: error?.localizedDescription))")
                self.actionPlaySpotifyTrack(spotifyTrackId: spotifyTrackId)
            }
        })
    }
    
    @objc func actionStopPlayer() {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.player?.logout()
            self.deactivateAudioSession()
//            do {
////                try self.player?.stop()
//            } catch { }
            
            UIApplication.shared.endReceivingRemoteControlEvents();
        }
    }
    
    /*
    func actionSeekForward() {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        
        if var nowPlayingInfo = nowPlayingInfo {
            let duration = nowPlayingInfo[MPMediaItemPropertyPlaybackDuration]! as! Double
            let elapsedTime = nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] as! Double
            let seekTime = elapsedTime + (duration / 20)
            if seekTime <= duration {
                player?.seek(to: seekTime, callback: { (error) in
                    if error != nil {
                        print("error seeking forward. Error: \(error?.localizedDescription)")
                    }
                    nowPlayingInfo.updateValue(seekTime, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime);
                    print(nowPlayingInfo)
                })
            }
        }
    }
    */
    
    @objc func actionSeekForward() {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        if var nowPlayingInfo = nowPlayingInfo {
            nowPlayingInfo.updateValue(3, forKey: MPNowPlayingInfoPropertyPlaybackRate);
            (MPNowPlayingInfoCenter.default().nowPlayingInfo)!.updateValue(3, forKey: MPNowPlayingInfoPropertyPlaybackRate);
        }
        
    }
    
    @objc func seekToTime() {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        if var nowPlayingInfo = nowPlayingInfo {
            /*
             let duration = nowPlayingInfo[MPMediaItemPropertyPlaybackDuration]! as! Double
             let elapsedTime = nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] as! Double
             let seekTime = elapsedTime + (duration / 20)
             if seekTime <= duration {
             
             }
             
             */
            let seekTime = nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] as! Double
            
            player?.seek(to: seekTime, callback: { (error) in
                if error != nil {
                    print("error seeking forward. Error: \(error?.localizedDescription)")
                }
                nowPlayingInfo.updateValue(seekTime, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime);
                nowPlayingInfo.updateValue(1, forKey: MPNowPlayingInfoPropertyPlaybackRate);
//                print(nowPlayingInfo)
            })
        }
        
    }
    
    
    @objc func actionSeekBackward() {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        if let nowPlayingInfo = nowPlayingInfo {
            let duration = nowPlayingInfo[MPMediaItemPropertyPlaybackDuration]! as! Double
            let elapsedTime = nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] as! Double
            let seekTime = elapsedTime - (duration / 20)
            if seekTime >= 0 {
                player?.seek(to: seekTime, callback: { (error) in
                    if error != nil {
                        print("error seeking forward. Error: \(error?.localizedDescription)")
                    }
                })
            }
        }
    }
    
    func updateNowPlayingCenter(title: String, artist: String, albumArt: AnyObject? = nil, currentTime: NSNumber, songLength: NSNumber, playbackRate: Double){
        
        var trackInfo: [String: AnyObject] = [
            
            MPMediaItemPropertyTitle: title as AnyObject,
            MPMediaItemPropertyArtist: artist as AnyObject,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime as AnyObject,
            MPMediaItemPropertyPlaybackDuration: songLength as AnyObject,
            MPNowPlayingInfoPropertyPlaybackRate: playbackRate as AnyObject
        ]
        
        var albumImage: MPMediaItemArtwork
        if albumArt != nil {
            albumImage = MPMediaItemArtwork(image: albumArt as! UIImage)
            trackInfo[MPMediaItemPropertyArtwork] = albumImage as AnyObject
        } else {
            albumImage = MPMediaItemArtwork(boundsSize: CGSize.zero, requestHandler: { (size) -> UIImage in
                return UIImage()
            })
        }
       
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = trackInfo as [String : AnyObject]
        }
        
        
    }
    
    
    // MARK: Activate audio session
    
    func activateAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
    }
    
    // MARK: Deactivate audio session
    
    func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false)
    }


}

