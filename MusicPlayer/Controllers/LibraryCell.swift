//
//  LibraryCell.swift
//  MusicPlayer
//
//  Created by Vlad Tkachuk on 27.05.2020.
//  Copyright © 2020 Vlad Tkachuk. All rights reserved.
//

import SwiftUI
import URLImage

struct LibraryCell: View {
    var cell: SearchViewModel.Cell
    
    var body: some View {
        HStack {
            URLImage(URL(string: cell.iconUrlString ?? "")!) { proxy in
                proxy.image.resizable()
            }
            .frame(width: 60, height: 60)
            .cornerRadius(2)
            VStack(alignment: .leading) {
                Text(self.cell.trackName)
                Text(self.cell.artistName)
            }
        }
    }
}

struct LibraryCell_Previews: PreviewProvider {
    static var previews: some View {
        LibraryCell(cell: .init(iconUrlString: "https://static.guides.co/a/uploads/2672%2F10B.+Icon.png", trackName: "TrackName", collectionName: "CollectionName", artistName: "ArtistName", previewUrl: "Preview"))
    }
}
