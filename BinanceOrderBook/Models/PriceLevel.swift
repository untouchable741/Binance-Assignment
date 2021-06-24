//
//  PriceLevel.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import Foundation

struct PriceLevel: Codable {
    let price: String
    let quantity: String
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.price = try container.decode(String.self)
        self.quantity = try container.decode(String.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(price)
        try container.encode(quantity)
    }
    
    init(price: String, quantity: String) {
        self.price = price
        self.quantity = quantity
    }
}
