//
//  Constants.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import Foundation
import UIKit

/// Define all configurable color of app in a protocol
/// Then we can have multiple theme configuration if desired

protocol AppThemeConfiguration {
    var bidTextColor: UIColor { get }
    var askTextColor: UIColor { get }
    var normalTextColor: UIColor { get }
    var bidDepthColor: UIColor { get }
    var askDepthColor: UIColor { get }
    var tintColor: UIColor { get }
    var inactiveColor: UIColor { get }
    var tabBarFont: UIFont { get }
    // More UIKit appearance navigationBarTintColor, tabBarTint, ... goes here
}

enum Theme {
    
    struct Default: AppThemeConfiguration {
        
        var bidTextColor: UIColor { .init(rgb: 0x10735A) }
        
        var askTextColor: UIColor { .init(rgb: 0xC10961) }
        
        var normalTextColor: UIColor { .lightText }
        
        var bidDepthColor: UIColor { .init(rgb: 0x10735A, alpha: 0.5) }
        
        var askDepthColor: UIColor { .init(rgb: 0xC10961, alpha: 0.5) }
        
        var tintColor: UIColor { .init(rgb: 0xFFC500) }
        
        var inactiveColor: UIColor { .lightText }
        
        var tabBarFont: UIFont { UIFont.systemFont(ofSize: 13) }
    }
    
    // struct DefaultForLightMode { }
    // struct DefaultForDarkMode { }
}

enum AppConstants {
    static let placeholderValue: String = "--"
    static let currentTheme = Theme.Default()
    // static let currentTheme = Theme.DefaultForLightMode()
    // static let currentTheme = Theme.DefaultForDarkMode()
}
