//
//  NIb.swift
//  MusicPlayer
//
//  Created by Vlad Tkachuk on 26.05.2020.
//  Copyright © 2020 Vlad Tkachuk. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    class func loadFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)?.first as! T
    }
}
