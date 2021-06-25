//
//  OrderBookCellViewModel.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import Foundation

final class OrderBookCellViewModel {
    private let isPlaceholder: Bool
    let bidPriceLevel: PriceLevel
    let askPriceLevel: PriceLevel
    let currencyPair: CurrencyPair
    let numberFormatter: NumberFormatter
    let bidQuantityPercentage: Decimal
    let askQuantityPercentage: Decimal
    
    init(
        isPlaceholder: Bool = false,
        bidPriceLevel: PriceLevel,
        askPriceLevel: PriceLevel,
        bidQuantityPercentage: Decimal,
        askQuantityPercentage: Decimal,
        currencyPair: CurrencyPair,
        numberFormatter: NumberFormatter = NumberFormatter.sharedNumberFormatter
    ) {
        self.isPlaceholder = isPlaceholder
        self.bidPriceLevel = bidPriceLevel
        self.askPriceLevel = askPriceLevel
        self.bidQuantityPercentage = bidQuantityPercentage
        self.askQuantityPercentage = askQuantityPercentage
        self.currencyPair = currencyPair
        self.numberFormatter = numberFormatter
    }
}


// MARK: - Computed properties

extension OrderBookCellViewModel {
    var formattedBidQuantity: String? {
        guard !isPlaceholder else {
            return "--"
        }
        return numberFormatter.quantityString(from: bidPriceLevel.quantity as NSDecimalNumber, of: currencyPair)
    }
    
    var formattedBidPrice: String? {
        guard !isPlaceholder else {
            return "--"
        }
        return numberFormatter.priceString(from: bidPriceLevel.price as NSDecimalNumber, of: currencyPair)
    }
    
    var formattedAskQuantity: String? {
        guard !isPlaceholder else {
            return "--"
        }
        return numberFormatter.quantityString(from: askPriceLevel.quantity as NSDecimalNumber, of: currencyPair)
    }
    
    var formattedAskPrice: String? {
        guard !isPlaceholder else {
            return "--"
        }
        return numberFormatter.priceString(from: askPriceLevel.price as NSDecimalNumber, of: currencyPair)
    }
}
