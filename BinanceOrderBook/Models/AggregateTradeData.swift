//
//  AggregateTradeData.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import Foundation

struct AggregateTradeData: Codable {
    let eventType: String?
    let eventTime: Date?
    let symbol: CurrencyPair?
    let tradeID: Int
    let price: String
    let quantity: String
    let firstTradeID: Int
    let lastTradeID: Int
    let tradeTime: Date
    let isBuyer: Bool
    
    enum CodingKeys : String, CodingKey {
        case eventType = "e"
        case eventTime = "E"
        case symbol = "s"
        case tradeID = "a"
        case price = "p"
        case firstTradeID = "f"
        case lastTradeID = "l"
        case quantity = "q"
        case tradeTime = "T"
        case isBuyer = "m"
    }
}
