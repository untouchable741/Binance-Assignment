//
//  DepthUpdateData.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import Foundation

struct DepthChartSocketResponse: Codable {
    let eventType: String
    let eventTime: Date
    let symbol: CurrencyPair
    let firstUpdateID: Int
    let finalUpdateID: Int
    let bids: [PriceLevel]
    let asks: [PriceLevel]
    
    enum CodingKeys : String, CodingKey {
        case eventType = "e"
        case eventTime = "E"
        case symbol = "s"
        case firstUpdateID = "U"
        case finalUpdateID = "u"
        case bids = "b"
        case asks = "a"
    }
}
