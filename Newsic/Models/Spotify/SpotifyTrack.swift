//
//  SpotifyTrack.swift
//  Nusic
//
//  Created by Miguel Alcantara on 29/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import UIKit

class SpotifyTrack: Hashable {
    var hashValue: Int {
        return trackId.hashValue
    }
    
    
    
    
    var title: String!;
    var thumbNail: UIImage?;
    var thumbNailUrl: String!;
    var trackId: String!;
    var trackUri: String!;
    var songName: String!;
    var artist: SpotifyArtist;
    var addedAt: Date?!
    var audioFeatures: SpotifyTrackFeature? = nil
    
    init(title: String? = "", thumbNail: UIImage? = nil, thumbNailUrl: String? = "", trackUri: String? = "", trackId: String, songName: String? = "", artist: SpotifyArtist?, addedAt: Date? = Date(), audioFeatures: SpotifyTrackFeature?) {
        self.title = title;
        self.thumbNailUrl = thumbNailUrl;
        self.trackUri = trackUri;
        self.trackId = trackId;
        self.songName = songName;
        self.artist = artist!
        self.addedAt = addedAt;
        self.audioFeatures = audioFeatures
        
        let image = UIImage()
        if let thumbNail = thumbNail {
            self.thumbNail = thumbNail
        } else {
            if let thumbNailUrl = thumbNailUrl {
                if let url = URL(string: thumbNailUrl) {
                    image.downloadImage(from: url) { (image) in
                        self.thumbNail = image;
                    }
                }
            }
        }
        
        
    }
    
    static func ==(lhs: SpotifyTrack, rhs: SpotifyTrack) -> Bool {
        return lhs.title == rhs.title &&
            lhs.thumbNail == rhs.thumbNail &&
            lhs.thumbNailUrl == rhs.thumbNailUrl &&
            lhs.trackId == rhs.trackId &&
            lhs.trackUri == rhs.trackUri &&
            lhs.songName == rhs.songName &&
            lhs.artist == rhs.artist &&
            lhs.addedAt == rhs.addedAt &&
            lhs.audioFeatures == rhs.audioFeatures
    }
    
    func setImage() {
        let image = UIImage()
        image.downloadImage(from: URL(string: thumbNailUrl)!) { (image) in
            self.thumbNail = image;
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }

}
