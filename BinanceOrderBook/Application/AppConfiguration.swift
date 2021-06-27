//
//  AppConfiguration.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import Foundation
 
/// We can use multiple xcconfig for thos configurations to separate it multiple environment
/// E.g: development.xcconfig , production.xcconfig
/// But in scope of this coding assignment i will just keep it simple by an AppConfiguration enum

enum AppConfiguration {
    static let websocketUrlString = "wss://stream.binance.com/stream"
    static let baseUrlString = "https://api.binance.com/api/v3"
    static let orderBookDefaultRowsCount = 25
    static let orderBookLimit = 50
    static let marketHistoryDefaultRowsCount = 25
    static let marketHistoryLimit = 80
}
