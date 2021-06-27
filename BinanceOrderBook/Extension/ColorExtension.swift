//
//  ColorExtension.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
   }

    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF,
           alpha: alpha
       )
   }
}
