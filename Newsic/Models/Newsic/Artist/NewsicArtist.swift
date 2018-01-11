//
//  NusicArtist.swift
//  Nusic
//
//  Created by Miguel Alcantara on 07/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct NusicArtist {
    
    let spotifyArtist: SpotifyArtist;
    let userName: String
    var reference: DatabaseReference!
    
    init(artist: SpotifyArtist, userName: String) {
        self.spotifyArtist = artist;
        self.userName = userName;
        self.reference = Database.database().reference().child("users");
    }
    
}

extension NusicArtist: FirebaseModel {
    
    internal func getData(getCompleteHandler: @escaping (NSDictionary?, NusicError?) -> ()) {
        reference.child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            getCompleteHandler(value, nil);
        }) { (error) in
            getCompleteHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getArtist.rawValue, systemError: error));
        }
        
        
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
//        let dict = ["name" : self.name]
//        reference.child(userName).child(self.id!).updateChildValues(dict) { (error, reference) in
//            saveCompleteHandler(reference, error)
//        }
        //        reference.child(userName).child(self.id!).updateChildValues(dict);
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        reference.child(userName).removeValue { (error, databaseReference) in
            if let error = error {
                deleteCompleteHandler(self.reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteArtist.rawValue, systemError: error))
            } else {
                deleteCompleteHandler(self.reference, nil)
            }
            
        }
    }
    
    
}
