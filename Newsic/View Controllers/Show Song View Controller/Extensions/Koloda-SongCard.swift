//
//  Koloda-SongCard.swift
//  Nusic
//
//  Created by Miguel Alcantara on 29/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit
import Koloda
import SwiftSpinner

extension ShowSongViewController: KolodaViewDelegate {
    
    func kolodaShouldMoveBackgroundCard(_ koloda: Koloda.KolodaView) -> Bool {
        return false;
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
        let alertController = NusicAlertController(title: nil, message: nil, style: YBAlertControllerStyle.ActionSheet)
        
        
        
        let actionShare: () -> Void = {
            var url: URL? = nil
            if self.user.settingValues.preferredPlayer == NusicPreferredPlayer.spotify {
                if let href = self.currentPlayingTrack?.songHref {
                    url = URL(string: href)
                } else {
                    return;
                }
            } else {
                if let ytId = self.currentPlayingTrack?.audioFeatures?.youtubeId {
                    url = URL(string: "https://www.youtube.com/watch?v=\(ytId)");
                } else {
                    return;
                }
            }
//            let url = URL(string:  (self.currentPlayingTrack?.songHref)!)!
            let appendedText = "Suggested by #nusic"
            let array: [Any] = [url as Any, appendedText as Any]
            let activityVC = UIActivityViewController(activityItems: array, applicationActivities: nil)
            activityVC.completionWithItemsHandler = { activity, isSuccess, returneditems, activityError in
                var spinnerMessage = ""
                if activity != nil {
                    if isSuccess {
                        spinnerMessage = "Shared!"
                    } 
                    
                    SwiftSpinner.show(duration: 2, title: spinnerMessage, animated: true)
                }
            }
            self.present(activityVC, animated: true, completion: nil)
        }
        
        let actionBasedOn: () -> Void = {
            alertController.dismiss()
            
            let actionArtist: () -> Void = {
                self.musicSearchType = .artist
                self.searchBasedOnArtist = self.currentPlayingTrack?.artist != nil ? self.currentPlayingTrack?.artist : nil
                self.showSwiftSpinner(text: "Fetching tracks..")
                self.showSwiftSpinner(delay: 20, text: "Unable to fetch!", duration: nil)
                self.showMore.transform = CGAffineTransform.identity;
                self.handleFetchNewTracks(numberOfSongs: 9, completionHandler: nil)
                
            }
            
            let actionTrack: () -> Void = {
                self.musicSearchType = .track
                self.searchBasedOnTrack = self.currentPlayingTrack != nil ? self.currentPlayingTrack! : nil
                self.showSwiftSpinner(text: "Fetching tracks..")
                self.showSwiftSpinner(delay: 20, text: "Unable to fetch!", duration: nil)
                self.handleFetchNewTracks(numberOfSongs: 9, completionHandler: nil)
            }
            
            let actionGenre: () -> Void = {
                let dict = self.currentPlayingTrack?.artist.listDictionary()
                let count: Int? = dict?.count
                if let count = count, count > 0 {
                    self.searchBasedOnGenres = dict!
                }
                
                self.showSwiftSpinner(text: "Fetching tracks..")
                self.showSwiftSpinner(delay: 20, text: "Unable to fetch!", duration: nil)
                self.musicSearchType = .genre
                self.handleFetchNewTracks(numberOfSongs: 9, completionHandler: nil)
            }
            
            let basedOnAlertController = NusicAlertController(title: "More tracks based on:", message: nil, style: YBAlertControllerStyle.ActionSheet)
            basedOnAlertController.addButton(icon: UIImage(named: "GenreIcon"), title: "Current Genre", action: actionGenre)
            basedOnAlertController.addButton(icon: UIImage(named: "ArtistIcon"), title: "Current Artist", action: actionArtist)
            basedOnAlertController.addButton(icon: UIImage(named: "TrackIcon"), title: "Current Track", action: actionTrack)
            alertController.dismissCompletion({ (isCompleted) in
                basedOnAlertController.show()
            })
        }
        
        alertController.addButton(icon: UIImage(named: "Share"), title: "Share", action: actionShare)
        alertController.addButton(icon: UIImage(named: "BasedOn"), title: "More tracks based on", action: actionBasedOn)
        
        
        alertController.show()
        
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        self.hideLikeButtons()
        didUserSwipe = true;
        pausePlay.setImage(UIImage(named: "PlayTrack"), for: .normal)
        if direction == .right {
            likeTrack(in: index);
        }
        didUserSwipe = false;
        getNextSong()

    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
//        print("showing card at: \(index)")
        DispatchQueue.main.async {
            self.songListTableView.reloadData()
        }
        presentedCardIndex = index
        let cardView = koloda.viewForCard(at: index) as! SongOverlayView
        if isPlayerMenuOpen {
            cardView.genreLabel.alpha = 0
            cardView.songArtist.alpha = 0
        }
        isSongLiked = containsTrack(trackId: cardList[index].trackInfo.trackId);
        toggleLikeButtons();
        
        if currentPlayingTrack?.trackId != cardList[index].trackInfo.trackId {
            if preferredPlayer == NusicPreferredPlayer.spotify {
                playCard(at: index)
            } else {
                if let youtubeTrackId = cardList[index].youtubeInfo?.trackId {
                    setupYTPlayer(for: cardView, with: youtubeTrackId)
                    ytPlayTrack()
                }
            }
        }
        
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true;
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return false
    }

    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        return 0.75
    }
    
    func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection) {
        print(finishPercentage)
        
    }
}


extension ShowSongViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        //print("card list count = \(cardList.count)")
        return cardList.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        //WORKAROUND: Because of concurrent reloading, we need to validate the indexes are valid.
        if index < cardList.count {
            return configure(index: index)
        }
        return UIView()
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        //print("viewForCardOverlayAt index \(index)")
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? SongOverlayView
    }
    
    func configure(index: Int) -> UIView {
        
        
        let view = UINib(nibName: "OverlayView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SongOverlayView
        
        //print("index = \(index) -> artist = \(self.cardList[index].trackInfo.artist!) and songName = \(self.cardList[index].trackInfo.songName!)");
        view.songArtist.text = self.cardList[index].trackInfo.artist.artistName
        view.songTitle.text = self.cardList[index].trackInfo.songName;
        view.genreLabel.text = self.cardList[index].trackInfo.artist.listGenres()
        view.albumImage.downloadedFrom(link: self.cardList[index].trackInfo.thumbNailUrl);
        
        //TODO: Swiping for Spotify shows YT view regardless, and as such, the album image is hidden.
        if preferredPlayer == NusicPreferredPlayer.spotify {
            view.setupViewForSpotify()
        } else {
            view.setupViewForYoutube()
        }
        
        view.layer.borderWidth = 0.5;
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 15
        view.clipsToBounds = true;
        
        return view;
    }
    
}

extension ShowSongViewController {
    
    func setupCards() {
        songCardView.delegate = self;
        songCardView.dataSource = self;
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(likeTrack(in:)));
        doubleTapRecognizer.numberOfTapsRequired = 2
        songCardView.addGestureRecognizer(doubleTapRecognizer);
        
        currentSongCardFrame = songCardView.frame
        
    }
    
    @objc func likeTrack(in index: Int) {
        guard cardList.count > 0, containsTrack(trackId: cardList[presentedCardIndex].trackInfo.trackId) == false else { return; }
        let likedCardIndex = presentedCardIndex
        SwiftSpinner.show("Adding track to playlist..").addTapHandler({
            SwiftSpinner.hide()
        }, subtitle: "Tap on the screen to go back to the cards. We'll add the song on the background!")
        
        let track = cardList[likedCardIndex];
        isSongLiked = didUserSwipe == true ? false : true ; toggleLikeButtons()
        spotifyHandler.isTrackInPlaylist(trackId: track.trackInfo.trackId, playlistId: playlist.id!) { (isInPlaylist) in
            if !isInPlaylist {
                self.spotifyHandler.addTracksToPlaylist(playlistId: self.playlist.id!, trackId: track.trackInfo.trackUri, addTrackHandler: { (isAdded, error) in
                    
                    if let error = error {
                        SwiftSpinner.hide()
                        error.presentPopup(for: self, description: SpotifyErrorCodeDescription.addTrack.rawValue)
                    } else {
                        if let genres = track.trackInfo.artist.subGenres {
                            for genre in genres {
                                self.user.updateGenreCount(for: genre, updateGenreHandler: { (isUpdated, error) in
                                    if let error = error {
                                        SwiftSpinner.hide()
                                        error.presentPopup(for: self)
                                    } else {
                                        SwiftSpinner.show(duration: 2, title: "Liked!");
                                    }
                                    
                                })
                            }
                        } else {
                            DispatchQueue.main.async {
                                SwiftSpinner.show(duration: 2, title: "Liked!");
                            }
                        }
                        
                    }
                    
                })
            }
        }
        
        spotifyHandler.getTrackDetails(trackId: track.trackInfo.trackId!, fetchedTrackDetailsHandler: { (trackFeatures, error) in
            if let error = error {
                SwiftSpinner.hide()
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getTrackInfo.rawValue)
            } else {
                if var trackFeatures = trackFeatures {
                    trackFeatures.youtubeId = track.youtubeInfo?.trackId;
//                    self.updateCurrentGenresAndFeatures { (genres, trackFeatures) in
//                        self.trackFeatures = trackFeatures;
//                    }
                    
                    track.trackInfo.audioFeatures = trackFeatures;
                    track.saveData(saveCompleteHandler: { (reference, error) in
                        if let error = error {
                            SwiftSpinner.hide()
                            error.presentPopup(for: self)
                        }
                        self.likedTrackList.insert(track, at: 0);
                        DispatchQueue.main.async {
                            self.songListTableView.reloadData();
                        }
                        
                    });
                }
            }
            
        })
    }
    
    func addSongToPosition(at indexPath: IndexPath, position: Int) {
        let nusicTrack = sectionSongs[indexPath.section][indexPath.row]
        cardList.insert(nusicTrack, at: position);
        
        songCardView.insertCardAtIndexRange(position..<position+1, animated: false);
        songCardView.delegate?.koloda(songCardView, didShowCardAt: position)
    }
    
    func getCurrentCardView() -> SongOverlayView {
        return songCardView.viewForCard(at: songCardView.currentCardIndex) as! SongOverlayView
    }
    
    func handleFetchNewTracks(numberOfSongs: Int, completionHandler: ((Bool) -> ())?) {
        fetchNewCardsFromSpotify(numberOfSongs: numberOfSongs) { (tracks) in
            DispatchQueue.main.async {
                self.cardList.removeSubrange(self.songCardView.currentCardIndex+1..<self.cardList.count)
                self.addSongsToCardList(for: nil, tracks: tracks)
                self.songCardView.reloadCardsInIndexRange(self.songCardView.currentCardIndex+1..<self.cardList.count)
                SwiftSpinner.hide()
                completionHandler?(true)
            }
        }
    }
    
    func removeCardBorderLayer() {
        if let index = self.view.layer.sublayers?.index(where: { (layer) -> Bool in
            return layer.name == "cardBorder"
        }) {
            let borderLayer = self.view.layer.sublayers![index]
            borderLayer.removeFromSuperlayer()
        }
    }
    
    func addCardBorderLayer() {
        removeCardBorderLayer()
        var frame = trackStackView.frame
        frame.origin = CGPoint(x: (frame.origin.x) - 4 , y: (frame.origin.y) - 4)
        frame.size = CGSize(width: (frame.width) + 8, height: (frame.height) + 8)
        
        let path = UIBezierPath()
        
        let pathOriginX = cardTitle.text != "" ? cardTitle.frame.origin.x + cardTitle.frame.width + 8 : cardTitle.frame.origin.x + 8
        path.move(to: CGPoint(x: pathOriginX, y: frame.origin.y - 8))
        path.addLine(to: CGPoint(x: frame.origin.x + frame.width - 8 , y: frame.origin.y - 8))
        let radius:CGFloat = 16
        path.addArc(withCenter: CGPoint(x: frame.origin.x + frame.width - 8, y: frame.origin.y + 8), radius: radius, startAngle: .pi*1.5, endAngle: 0, clockwise: true)
        
        path.addLine(to: CGPoint(x: frame.origin.x + frame.width + 8, y: frame.origin.y + frame.height - 8))
        path.addArc(withCenter: CGPoint(x: frame.origin.x + frame.width - 8, y: frame.origin.y + frame.height - 8), radius: radius, startAngle: 0, endAngle: .pi*0.5, clockwise: true)
        
        path.addLine(to: CGPoint(x: frame.origin.x + 8 , y: frame.origin.y + frame.height + 8))
        path.addArc(withCenter: CGPoint(x: frame.origin.x + 8, y: frame.origin.y + frame.height - 8), radius: radius, startAngle: .pi*0.5, endAngle: .pi, clockwise: true)
        
        path.addLine(to: CGPoint(x: frame.origin.x - 8, y: frame.origin.y + 8))
        path.addArc(withCenter: CGPoint(x: frame.origin.x + 8, y: frame.origin.y + 8), radius: radius, startAngle: .pi, endAngle: .pi*1.5, clockwise: true)
        
        path.addLine(to: CGPoint(x: frame.origin.x + 16, y: frame.origin.y - 8))
        if cardTitle.text == "" {
            path.close()
        }
        let layer = CAShapeLayer()
        layer.name = "cardBorder"
        layer.path = path.cgPath
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 2
        layer.fillColor = UIColor.clear.cgColor
        
        let colors = [NusicDefaults.foregroundThemeColor, NusicDefaults.clearColor]
        self.view.layer.removeGradientLayer(name: "borderGradientLayer")
        self.view.layer.addGradientBorder(name: "borderGradientLayer", path: path.cgPath, colors: colors, width: 3)
        
        self.view.layer.removeAllAnimations()
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 2
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "border")
    }
}



