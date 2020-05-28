//
//  TrackCell.swift
//  MusicPlayer
//
//  Created by Vlad Tkachuk on 26.05.2020.
//  Copyright © 2020 Vlad Tkachuk. All rights reserved.
//

import UIKit
import SDWebImage

protocol TrackCellViewModel {
    var iconUrlString: String? { get }
    var trackName: String { get }
    var artistName: String { get }
    var collectionName: String { get }
}

class TrackCell: UITableViewCell {
    
    static let reuseId = "TrackCell"
    private var cell: SearchViewModel.Cell!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var collectionNameLabel: UILabel!
    @IBOutlet weak var addTrackButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.trackImageView.image = nil
        self.addTrackButton.isHidden = false
    }
    
    @IBAction func addTrack(_ sender: Any) {
        guard let cell = self.cell else {
            return
        }
        self.addTrackButton.isHidden = true
        var listOfTracks = UserDefaults.standard.getSavedTracks()
        listOfTracks.append(cell)
        UserDefaults.standard.saveTracks(track: listOfTracks)
    }
    
    func set(viewModel: SearchViewModel.Cell) {
        let savedTracks = UserDefaults.standard.getSavedTracks().filter {viewModel.isEqual($0)}
        if !savedTracks.isEmpty { self.addTrackButton.isHidden = true }
        
        self.cell = viewModel
        self.trackNameLabel.text = viewModel.trackName
        self.artistNameLabel.text = viewModel.artistName
        self.collectionNameLabel.text = viewModel.collectionName
        guard let url = URL(string: viewModel.iconUrlString ?? "") else { return }
        trackImageView.sd_setImage(with: url, completed: nil)
    }

}
