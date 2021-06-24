//
//  CurrencyPair.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

enum CurrencyPair: String, Codable {
    case BTCUSDT
}

struct FractionNumber {
    let min: Int
    let max: Int
}

// MARK: - Params

extension CurrencyPair {
    var depthStream: String {
        return "\(self.rawValue.lowercased())@depth"
    }
    
    var aggregateTrade: String {
        return "\(self.rawValue.lowercased())@aggTrade"
    }
    
    var priceFractionNumber: FractionNumber {
        switch self {
        case .BTCUSDT:
            return FractionNumber(min: 2, max: 2)
        }
    }
    
    var quantityFractionNumber: FractionNumber {
        switch self {
        case .BTCUSDT:
            return FractionNumber(min: 6, max: 6)
        }
    }
}
