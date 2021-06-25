//
//  NumberFormatter.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 25/06/2021.
//

import Foundation

// MARK: - OrderBookNumberFormatter

protocol OrderBookNumberFormatter {
    func quantityString(from number: NSDecimalNumber, of currencyPair: CurrencyPair) -> String?
    func priceString(from number: NSDecimalNumber, of currencyPair: CurrencyPair) -> String?
}

extension NumberFormatter: OrderBookNumberFormatter {
    func quantityString(from number: NSDecimalNumber,of currencyPair: CurrencyPair) -> String? {
        minimumFractionDigits = currencyPair.quantityFraction.min
        maximumFractionDigits = currencyPair.quantityFraction.max
        return string(from: number)
    }
    
    func priceString(from number: NSDecimalNumber, of currencyPair: CurrencyPair) -> String? {
        minimumFractionDigits = currencyPair.priceFraction.min
        maximumFractionDigits = currencyPair.priceFraction.max
        return string(from: number)
    }
}

// MARK: - TradeHistoryNumberFormattter

// MARK: - Shared formatter

extension NumberFormatter {
    static let sharedNumberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = true
        return numberFormatter
    }()
}
