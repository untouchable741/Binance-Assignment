//
//  AppDelegate.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureAppAppearance(theme: AppConstants.currentTheme)
        return true
    }
    
    func configureAppAppearance(theme: AppThemeConfiguration) {
        // UIKit appearance configuration goes here ...
        // UINavigationBar.appearance().tintColor = theme.tintColor
    }
}

