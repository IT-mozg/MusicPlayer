//
//  CMTime + Extension.swift
//  MusicPlayer
//
//  Created by Vlad Tkachuk on 26.05.2020.
//  Copyright © 2020 Vlad Tkachuk. All rights reserved.
//

import Foundation
import ARKit

extension CMTime {
    func toDisplayString() -> String {
        guard !CMTimeGetSeconds(self).isNaN else { return "00:00" }
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
