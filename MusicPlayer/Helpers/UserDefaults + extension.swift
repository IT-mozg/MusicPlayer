//
//  UserDefaults + extension.swift
//  MusicPlayer
//
//  Created by Vlad Tkachuk on 27.05.2020.
//  Copyright © 2020 Vlad Tkachuk. All rights reserved.
//

import Foundation

extension UserDefaults {
    static let favoriteTrackKey = "favoriteTrackKey"
    
    func getSavedTracks() -> [SearchViewModel.Cell] {
        let defaults = UserDefaults.standard
        
        guard let savedTracks = defaults.object(forKey: UserDefaults.favoriteTrackKey) as? Data else { return [] }
        guard let decodedTracks = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedTracks) as? [SearchViewModel.Cell] else { return [] }
        return decodedTracks
    }
    
    func saveTracks(track: [SearchViewModel.Cell]) {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: track, requiringSecureCoding: false) {
            UserDefaults.standard.set(savedData, forKey: UserDefaults.favoriteTrackKey)
        }
    }
}
