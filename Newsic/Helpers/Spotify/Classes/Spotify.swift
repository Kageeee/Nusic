//
//  Spotify.swift
//  Nusic
//
//  Created by Miguel Alcantara on 30/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

class Spotify {
    
    fileprivate var genreList:[String] = ["acoustic", "afrobeat", "alt-rock", "alternative", "ambient", "anime", "black-metal", "bluegrass", "blues", "bossanova", "brazil", "breakbeat", "british", "cantopop", "chicago-house", "children", "chill", "classical", "club", "comedy", "country", "dance", "dancehall", "death-metal", "deep-house", "detroit-techno", "disco", "disney", "drum-and-bass", "dub", "dubstep", "edm", "electro", "electronic", "emo", "folk", "forro", "french", "funk", "garage", "german", "gospel", "goth", "grindcore", "groove", "grunge", "guitar", "happy", "hard-rock", "hardcore", "hardstyle", "heavy-metal", "hip-hop", "holidays", "honky-tonk", "house", "idm", "indian", "indie", "indie-pop", "industrial", "iranian", "j-dance", "j-idol", "j-pop", "j-rock", "jazz", "k-pop", "kids", "latin", "latino", "malay", "mandopop", "metal", "metal-misc", "metalcore", "minimal-techno", "movies", "mpb", "new-age", "new-release", "opera", "pagode", "party", "philippines-opm", "piano", "pop", "pop-film", "post-dubstep", "power-pop", "progressive-house", "psych-rock", "punk", "punk-rock", "r-n-b", "rainy-day", "reggae", "reggaeton", "road-trip", "rock", "rock-n-roll", "rockabilly", "romance", "sad", "salsa", "samba", "sertanejo", "show-tunes", "singer-songwriter", "ska", "sleep", "songwriter", "soul", "soundtracks", "spanish", "study", "summer", "swedish", "synth-pop", "tango", "techno", "trance", "trip-hop", "turkish", "work-out", "world-music"]
    static let swapURL: String! = "https://newsic-spotifytokenrefresh.herokuapp.com/swap"
    static let refreshURL: String! = "https://newsic-spotifytokenrefresh.herokuapp.com/refresh"
    static let redirectURI: String! = "newsic://callback"
    static let clientId: String! = "82b9329aa00c415f8123445414d473fa"
    static let getAllArtistsForPlaylistUrl: String! = ""
    static let getAllGenresForArtistsUrl: String! = ""
    static let getAllPlaylistsUrl: String! = ""
    static let getFollowedArtistsForUser: String! = ""
    static let getTrackDetailsUrl: String! = ""
    static let getUserUrl: String! = ""
    static let searchMusicForGenresUrl: String! = ""
    var auth: SPTAuth! = SPTAuth.defaultInstance();
    var user: SPTUser! = nil;
    var genreCount: [String: Int] = [:]
    
    func getGenreForTrack(trackId: String, trackGenreHandler: @escaping([String]?, NusicError?) -> ()) {
        getTrackArtist(trackId: trackId) { (fetchedArtistId, error) in
            if error != nil {
                trackGenreHandler(nil, error)
            } else {
                if let fetchedArtistId = fetchedArtistId {
                    self.getGenresForArtist(artistId: fetchedArtistId, fetchedArtistGenresHandler: { (artistGenres, error) in
                        trackGenreHandler(artistGenres, nil);
                    })
                }
            }
        }
    }
    
    func getGenresForTrackList(trackIdList: [String], trackGenreHandler: @escaping([String]?, NusicError?) -> ()) {
        let count = trackIdList.count;
        var index = 0
        var allGenres:[String] = [];
        
        if trackIdList.count == 0 {
            trackGenreHandler(nil, nil)
        } else {
            for trackId in trackIdList {
                getGenreForTrack(trackId: trackId, trackGenreHandler: { (genres, error) in
                    if error != nil {
                        trackGenreHandler(nil, error)
                    } else {
                        if let genres = genres {
                            allGenres.append(contentsOf: genres)
                        }
                        index += 1
                        if index == count {
                            trackGenreHandler(allGenres, nil);
                        }
                    }
                })
            }
        }
    }
    
    
    func getAverageTrackFeatures(preferredTrackFeatures: [SpotifyTrackFeature]) -> [String: AnyObject] {
        let trackCount = Double(preferredTrackFeatures.count)
        var emotionValues:[String: AnyObject] = [:]
        
        var acousticness:Double = 0
        var danceability:Double = 0
        var energy:Double = 0
        var instrumentalness:Double = 0
        var liveness:Double = 0
        var loudness:Double = 0
        var speechiness:Double = 0
        var tempo:Double = 0
        var valence:Double = 0
        
        
        
        for trackFeatures in preferredTrackFeatures {
            
            acousticness = trackFeatures.acousticness != nil ? acousticness + trackFeatures.acousticness! : 0
            danceability = trackFeatures.danceability != nil ? danceability + trackFeatures.danceability! : 0
            energy = trackFeatures.energy != nil ? energy + trackFeatures.energy! : 0
            instrumentalness = trackFeatures.instrumentalness != nil ? instrumentalness + trackFeatures.instrumentalness! : 0
            liveness = trackFeatures.liveness != nil ? liveness + trackFeatures.liveness! : 0
            loudness = trackFeatures.loudness != nil ? loudness + trackFeatures.loudness! : 0
            speechiness = trackFeatures.speechiness != nil ? speechiness + trackFeatures.speechiness! : 0
            tempo = trackFeatures.tempo != nil ?  tempo + trackFeatures.tempo! : 0
            valence = trackFeatures.valence != nil ? valence + trackFeatures.valence! : 0
        }
        
        acousticness = (acousticness/Double(trackCount));
        acousticness.randomInRange(value: acousticness, range: 0.2, acceptNegativeValues: false)
        danceability = danceability/Double(trackCount);
        danceability.randomInRange(value: danceability, range: 0.2, acceptNegativeValues: false)
        energy = energy/Double(trackCount);
        energy.randomInRange(value: energy, range: 0.2, acceptNegativeValues: false)
        instrumentalness = instrumentalness/Double(trackCount);
        instrumentalness.randomInRange(value: instrumentalness, range: 0.2, acceptNegativeValues: false)
        liveness = liveness/Double(trackCount);
        liveness.randomInRange(value: liveness, range: 3, acceptNegativeValues: true)
        loudness = loudness/Double(trackCount);
        loudness.randomInRange(value: loudness, range: 0.2, acceptNegativeValues: false)
        speechiness = speechiness/Double(trackCount);
        speechiness.randomInRange(value: speechiness, range: 0.2, acceptNegativeValues: false)
        tempo = tempo/Double(trackCount);
        tempo.randomInRange(value: tempo, range: 100, acceptNegativeValues: false, maxValue: 250)
        valence = valence/Double(trackCount);
        valence.randomInRange(value: valence, range: 0.2, acceptNegativeValues: false)
        
        if preferredTrackFeatures.first?.acousticness != nil {
            emotionValues["acousticness"] = acousticness as AnyObject
        }
        
        if preferredTrackFeatures.first?.danceability != nil {
            emotionValues["danceability"] = danceability as AnyObject
        }
        
        if preferredTrackFeatures.first?.energy != nil {
            emotionValues["energy"] = energy as AnyObject
        }
        
        if preferredTrackFeatures.first?.instrumentalness != nil {
            emotionValues["instrumentalness"] = instrumentalness as AnyObject
        }
        
        if preferredTrackFeatures.first?.liveness != nil {
            emotionValues["liveness"] = liveness as AnyObject
        }
        
        if preferredTrackFeatures.first?.loudness != nil {
            emotionValues["loudness"] = loudness as AnyObject
        }
        
        if preferredTrackFeatures.first?.speechiness != nil {
            emotionValues["speechiness"] = speechiness as AnyObject
        }
        
        if preferredTrackFeatures.first?.tempo != nil {
            emotionValues["tempo"] = tempo as AnyObject
        }
        
        if preferredTrackFeatures.first?.valence != nil {
            emotionValues["valence"] = valence as AnyObject
        }
        
        return emotionValues;
    }
    
    func trackFeaturesToString(features: [String: AnyObject]) -> String {
        var result = "&"
        var iterator = features.makeIterator();
        
        var nextElement = iterator.next();
        
        while nextElement != nil {
            if let element = nextElement {
                let key = element.key
                let value = element.value as! Double
                
                result += "target_\(key)=\(value.roundToDecimalPlaces(places: 3))&"
            }
            
            
            nextElement = iterator.next();
        }
        
//        let index = result.index(before: result.endIndex);
//        return result.substring(to: index);
        result.removeLast()
        return result;
    }
    
    func getRandomGenreBasedOnPercentage(hasGenreListForEmotion: Bool, selectedGenreList: [String: Int]? = nil) -> String{
        let sortedKeys: [(key: String, value:Int)];
        if selectedGenreList == nil {
            sortedKeys = genreCount.sorted(by: { $0.value > $1.value })
        } else {
            sortedKeys = (selectedGenreList?.sorted(by: { $0.value > $1.value }))!;
        }
        
        var percentagesString: [String] = []
        let percentageRate:Double = hasGenreListForEmotion ? 50 : 100
        
        
        for keyValue in sortedKeys {
            let percentage = (Double(keyValue.value)/Double(sortedKeys.count))*percentageRate
            let percentageInt = Int(percentage)
            for _ in 0..<percentageInt {
                percentagesString.append(keyValue.key)
            }
        }
        
        let randomIndex = Int.random(range: 1..<percentagesString.count);
        return percentagesString[randomIndex];
        
    }
    
    func getGenreCount(for artistList: [SpotifyArtist]) -> [String: Int] {
        var countDictionary:[String: Int] = genreCount;
        
        for artist in artistList {
            if let subGenres = artist.subGenres {
                for subGenre in subGenres {
                    if genreList.contains(subGenre) {
                        if countDictionary.index(forKey: subGenre) != nil {
                            countDictionary.updateValue(countDictionary[subGenre]!+1, forKey: subGenre)
                        } else {
                            countDictionary[subGenre] = 1;
                        }
                    }
                }
            }
        }
        genreCount = countDictionary
        
        return genreCount;
    }
    
    func filterSpotifyGenres(genres: [String]) -> [String] {
        
        var filteredList: [String] = []
        for genre in genres {
            if genreList.contains(genre) {
                filteredList.append(genre)
            }
        }
        return filteredList;
    }
    
    func getGenreListString(numberOfSongs:Int, hasList: Bool, selectedGenreList:[String: Int]? = nil) -> String {
        var hasList = hasList
        var index = 0
        var genres = ""
        var genreListCount = 0
        var totalCount = genreListCount
        var selectedGenreList = selectedGenreList
        
        if let selectedGenreList = selectedGenreList, selectedGenreList.count > 0 {
            genreListCount = selectedGenreList.count
        } else {
            hasList = false
            selectedGenreList = nil
            if genreCount.count < numberOfSongs && genreCount.count > 0 {
                var list: String = ""
                for keyValue in genreCount {
                    if index > 4 {
                        break;
                    }
                    index += 1
                    list.append("\(keyValue.key),")
                }
                list.removeLast()
                return list
                
            } else {
                genreListCount = numberOfSongs
            }
        }
        
        totalCount = genreListCount
        
        //NOTE: Spotify recommendations max seed genres is 5. This is a workaround by fixing the max count to 5.
        if numberOfSongs > 5 && genreListCount > 5 {
           totalCount = 5
        }
        
        while index < totalCount {
            var separator = ","
            if index == totalCount-1 {
                separator = ""
            }
            var genre = getRandomGenreBasedOnPercentage(hasGenreListForEmotion: hasList, selectedGenreList: selectedGenreList);
            genre = genre.replacingOccurrences(of: " ", with: "-")
            if !genres.contains(genre) {
                genres += "\(genre)\(separator)"
            } else {
                index -= 1;
            }
            
            index += 1;
        }
        return genres;
    }
    
    func getRefreshToken(currentSession: SPTSession, refreshTokenCompletionHandler: @escaping (Bool) -> ()) {
        let userDefaults = UserDefaults.standard;
        SPTAuth.defaultInstance().renewSession(currentSession, callback: { (error, session) in
            if error == nil {
//                print("refresh successful");
                let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
                userDefaults.set(sessionData, forKey: "SpotifySession")
                userDefaults.synchronize()
                
                self.auth.session = session;
                refreshTokenCompletionHandler(true)
            } else {
//                print("error refreshing session: \(error?.localizedDescription)");
                refreshTokenCompletionHandler(false)
            }
            
        })
    }
    
    func executeSpotifyCall(with request: URLRequest, retryNumber: Int? = 3, retryAfter: Int? = 2, spotifyCallCompletionHandler: @escaping (Data?, HTTPURLResponse?, Error?, Bool) -> ()) {
        let session = URLSession.shared;
        session.executeCall(with: request) { (data, response, error, isSuccess) in
            let statusCode = response?.statusCode
            if let error = error {
                spotifyCallCompletionHandler(data, response, error, false);
            } else {
                if isSuccess {
                    spotifyCallCompletionHandler(data, response, error, true)
                } else {
                    switch statusCode! {
                    case 400...499:
                        if statusCode == HTTPErrorCodes.unauthorized.rawValue {
                            self.getRefreshToken(currentSession: self.auth.session, refreshTokenCompletionHandler: { (isRefreshSuccessful) in
                                if isRefreshSuccessful {
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.auth = self.auth
                                    if let url = request.url {
                                        var newRequest = URLRequest(url: url);
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshSuccessful"), object: nil);
                                        newRequest.addValue("Bearer \(self.auth.session.accessToken!)", forHTTPHeaderField: "Authorization");
                                        self.executeSpotifyCall(with: newRequest, spotifyCallCompletionHandler: spotifyCallCompletionHandler)
                                    }
                                } else {
                                    spotifyCallCompletionHandler(data, response, error, isSuccess);
                                }
                            })
                        }
                    case 500...599:
                        spotifyCallCompletionHandler(data, response, error, false);
                    default:
                        spotifyCallCompletionHandler(data, nil, error, false);
                    }
                }
            }
            
        }
    }
    
    // STATIC FUNCTIONS
    
    static func transformToURI(type: SpotifyType, id: String) -> String {
        return "\(type.rawValue)\(id)"
    }
    
    static func transformToID(type: SpotifyType, uri: String) -> String {
        var uri = uri
        uri.removeSubrange(uri.range(of: type.rawValue)!)
        return uri
    }
    
    static func getAllValuesDict() -> [String: Int] {
        var dict: [String: Int] = [:]
        for value in SpotifyGenres.allShownValues {
            dict[value.rawValue.lowercased()] = 1
        }
        return dict
    }
}
