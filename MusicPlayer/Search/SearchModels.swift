//
//  SearchModels.swift
//  MusicPlayer
//
//  Created by Vlad Tkachuk on 25.05.2020.
//  Copyright (c) 2020 Vlad Tkachuk. All rights reserved.
//

import UIKit
import SwiftUI

enum Search {
    
    enum Model {
        struct Request {
            enum RequestType {
                case getTracks(searchTerm: String)
                case removeTracks
            }
        }
        struct Response {
            enum ResponseType {
                case presentTracks(searchResponce: SearchResponce?)
                case presentFooterView
                case presentEmptyResponse
            }
        }
        struct ViewModel {
            enum ViewModelData {
                case displayTracks(searchViewModel: SearchViewModel)
                case displayFooterView
            }
        }
    }
    
}

protocol Comparable {
    func compare(with object: Comparable) -> Bool
}

class SearchViewModel: NSObject, NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(cells, forKey: "cells")
    }
    
    required init?(coder: NSCoder) {
        cells = coder.decodeObject(forKey: "cells") as? [SearchViewModel.Cell] ?? []
    }
    
    @objc(SearchViewModelCell)class Cell: NSObject, NSCoding, Identifiable {
        var id: UUID = UUID()
        
        var iconUrlString: String?
        var trackName: String
        var collectionName: String
        var artistName: String
        var previewUrl: String?
        
        init(iconUrlString: String?, trackName: String, collectionName: String, artistName: String, previewUrl: String?) {
            self.iconUrlString = iconUrlString
            self.trackName = trackName
            self.collectionName = collectionName
            self.artistName = artistName
            self.previewUrl = previewUrl
        }
        
        func encode(with coder: NSCoder) {
            coder.encode(self.iconUrlString, forKey: "iconUrlString")
            coder.encode(self.trackName, forKey: "trackName")
            coder.encode(self.collectionName, forKey: "collectionName")
            coder.encode(self.artistName, forKey: "artistName")
            coder.encode(self.previewUrl, forKey: "previewUrl")
        }
        
        required init?(coder: NSCoder) {
            iconUrlString = coder.decodeObject(forKey: "iconUrlString") as? String
            trackName = coder.decodeObject(forKey: "trackName") as? String ?? ""
            collectionName = coder.decodeObject(forKey: "collectionName") as? String ?? ""
            artistName = coder.decodeObject(forKey: "artistName") as? String ?? ""
            previewUrl = coder.decodeObject(forKey: "previewUrl") as? String ?? ""
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let object = object as? Cell else { return false }
            guard self.iconUrlString == object.iconUrlString,
                self.artistName == object.artistName,
                self.collectionName == object.collectionName,
                self.previewUrl == object.previewUrl,
                self.trackName == object.trackName else { return false }
            return true
        }
    }
    
    let cells: [Cell]
    
    init(cells: [Cell]) {
        self.cells = cells
    }
}
