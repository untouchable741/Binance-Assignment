//
//  AppConfiguration.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import Foundation

enum AppConfiguration {
    static let websocketUrlString = "wss://stream.binance.com/stream"
    static let baseUrlString = "https://api.binance.com/api/v3"
    static let orderBookDefaultRowsCount = 25
    static let orderBookLimit = 50
}
