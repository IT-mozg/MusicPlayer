//
//  UIViewController + Storyboard.swift
//  MusicPlayer
//
//  Created by Vlad Tkachuk on 25.05.2020.
//  Copyright © 2020 Vlad Tkachuk. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    class func loadFromStoryboard<T: UIViewController>() -> T {
        let name = String(describing: T.self)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() as? T {
            return vc
        }
        fatalError("Error: No inital view controller in \(name) storyboard")
    }
}
