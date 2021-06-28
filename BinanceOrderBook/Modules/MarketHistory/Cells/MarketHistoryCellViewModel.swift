//
//  MarketHistoryCellViewModel.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import Foundation

protocol MarketHistoryCellViewModelProtocol {
    var formattedTradeTime: String? { get }
    var formattedPrice: String? { get }
    var formattedQuantity: String? { get }
    var isBuyer: Bool { get }
}

final class MarketHistoryCellViewModel {
    let aggregateTradeData: AggregateTradeData
    let currencyPair: CurrencyPair
    let numberFormatter: NumberFormatter
    let dateFormatter: DateFormatter
    
    init(
        aggregateData: AggregateTradeData,
        currencyPair: CurrencyPair,
        numberFormatter: NumberFormatter = NumberFormatter.sharedNumberFormatter,
        dateFormatter: DateFormatter = DateFormatter.sharedDateFormatter
    ) {
        self.aggregateTradeData = aggregateData
        self.numberFormatter = numberFormatter
        self.dateFormatter = dateFormatter
        self.currencyPair = currencyPair
    }
}

// MARK: - Computed properties

extension MarketHistoryCellViewModel: MarketHistoryCellViewModelProtocol {
    var formattedTradeTime: String? {
        return dateFormatter.timeString(from: aggregateTradeData.tradeTime)
    }
    
    var formattedPrice: String? {
        return numberFormatter.priceString(from: NSDecimalNumber(string: aggregateTradeData.price), of: currencyPair)
    }
    
    var formattedQuantity: String? {
        return numberFormatter.quantityString(from: NSDecimalNumber(string: aggregateTradeData.quantity), of: currencyPair)
    }
    
    var isBuyer: Bool {
        return aggregateTradeData.isBuyer
    }
}

final class PlacaholderMarketHistoryCellViewModel: MarketHistoryCellViewModelProtocol {
    var formattedTradeTime: String? {
        return AppConstants.placeholderValue
    }
    
    var formattedPrice: String? {
        return AppConstants.placeholderValue
    }
    
    var formattedQuantity: String? {
        return AppConstants.placeholderValue
    }
    
    var isBuyer: Bool {
        return true
    }
}
