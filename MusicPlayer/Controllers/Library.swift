//
//  LIbrary.swift
//  MusicPlayer
//
//  Created by Vlad Tkachuk on 27.05.2020.
//  Copyright © 2020 Vlad Tkachuk. All rights reserved.
//

import SwiftUI
import UIKit

struct Library: View {
    @State var tracks = UserDefaults.standard.getSavedTracks()
    @State private var showingAlert = false
    @State var clickedTrack: SearchViewModel.Cell!
    
    weak var trackDetailView: TrackDetailView?
    
    var body: some View {
        NavigationView {
            VStack() {
                GeometryReader { geometry in
                    HStack(spacing: 20.0) {
                        LibraryButton(systemName: "play.fill", width: geometry.size.width / 2 - 10) {
                            self.clickedTrack = self.tracks[0]
                            self.trackDetailView?.switchDelegate = self
                            self.trackDetailView?.transitionDelegate?.maximizeTrackDetailController(viewModel: self.clickedTrack)
                        }
                        LibraryButton(systemName: "arrow.2.circlepath", width: geometry.size.width / 2 - 10) {
                            self.tracks = UserDefaults.standard.getSavedTracks()
                        }
                    }
                    
                }.padding().frame(height: 50)
                
                Divider()
                    .padding(.leading)
                    .padding(.trailing)
                Spacer()
                List {
                    ForEach(tracks) { track in
                        LibraryCell(cell: track)
                            .gesture(LongPressGesture()
                                .onEnded{ _ in
                                    self.clickedTrack = track
                                    self.showingAlert = true
                            }.simultaneously(with: TapGesture()
                                .onEnded{ _ in
                                    self.trackDetailView?.switchDelegate = self
                                    self.clickedTrack = track
                                    self.trackDetailView?.transitionDelegate?.maximizeTrackDetailController(viewModel: self.clickedTrack)
                            }))
                        
                    }.onDelete(perform: delete(at:))
                }
            }.actionSheet(isPresented: $showingAlert, content: { () -> ActionSheet in
                ActionSheet(title: Text("Are you sure you want to delete thi s track"),
                            buttons: [
                                .destructive(Text("Delete"), action: {
                                    self.delete(track: self.clickedTrack)
                                }), .cancel()])
            })
                .navigationBarTitle("Library")
            
        }
    }
    
    private func delete(at offsets: IndexSet) {
        tracks.remove(atOffsets: offsets)
        UserDefaults.standard.saveTracks(track: tracks)
    }
    
    private func delete(track: SearchViewModel.Cell) {
        guard let index = tracks.firstIndex(of: track) else { return }
        tracks.remove(at: index)
        UserDefaults.standard.saveTracks(track: tracks)
    }
}

struct LibraryButton: View {
    var systemName: String
    var width: CGFloat
    var action: () -> Void
    
    var body: some View {
        
        Button(action: {
            self.action()
        }) {
            Image(systemName: self.systemName)
                .frame(width: width, height: 50)
                .accentColor(Color.init(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)))
                .background(Color.init(#colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9137254902, alpha: 1)))
                .cornerRadius(10)
        }
    }
}

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        Library()
    }
}

extension Library: TrackSwitchDelegate {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
        guard let index = self.tracks.firstIndex(of: self.clickedTrack) else { return nil }
        var nexTrack: SearchViewModel.Cell
        if index - 1 == -1 {
            nexTrack = tracks[tracks.count - 1]
        } else {
            nexTrack = tracks[index - 1]
        }
        self.clickedTrack = nexTrack
        return nexTrack
    }
    
    func moveForwardForPreviousTrack() -> SearchViewModel.Cell? {
        guard let index = self.tracks.firstIndex(of: self.clickedTrack) else { return nil }
        var nexTrack: SearchViewModel.Cell
        if index + 1 == tracks.count {
            nexTrack = tracks[0]
        } else {
            nexTrack = tracks[index + 1]
        }
        self.clickedTrack = nexTrack
        return nexTrack
    }
}
