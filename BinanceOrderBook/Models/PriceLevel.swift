//
//  PriceLevel.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import Foundation

struct PriceLevel: Codable {
    let price: Decimal
    let quantity: Decimal
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.price = Decimal(string: try container.decode(String.self)) ?? 0
        self.quantity = Decimal(string: try container.decode(String.self)) ?? 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode((price as NSDecimalNumber).stringValue)
        try container.encode((quantity as NSDecimalNumber).stringValue)
    }
    
    init(price: Decimal, quantity: Decimal) {
        self.price = price
        self.quantity = quantity
    }
}
