//
//  NusicPreferredPlayer.swift
//  Nusic
//
//  Created by Miguel Alcantara on 11/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

enum NusicPreferredPlayer: Int {
    case spotify
    case youtube
    
    func description() -> String {
        switch self {
        case .spotify:
            return "Spotify"
        case .youtube:
            return "YouTube"
        }
    }
}
