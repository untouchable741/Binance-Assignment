//
//  CurrencyPair.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

enum CurrencyPair: String, Codable {
    case BTCUSDT
}

// MARK: - Params

extension CurrencyPair: FractionConfigurable {
    var quantityFraction: FractionConfiguration {
        switch self {
        case .BTCUSDT:
            return FractionConfiguration(min: 6, max: 6)
        }
    }
    
    var priceFraction: FractionConfiguration {
        switch self {
        case .BTCUSDT:
            return FractionConfiguration(min: 2, max: 2)
        }
    }
    
    var depthStream: String {
        return "\(self.rawValue.lowercased())@depth"
    }
    
    var aggregateTrade: String {
        return "\(self.rawValue.lowercased())@aggTrade"
    }
}
