//
//  MarketHistoryCellViewModelTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
@testable import BinanceOrderBook

final class MarketHistoryCellViewModelTests: XCTestCase {

    var sut: MarketHistoryCellViewModelProtocol!
    
    func testViewModelComputedProperties() {
        // Given
        let currencyPair = CurrencyPair.BTCUSDT
        let aggregateData = AggregateTradeData(
            eventType: "event_type",
            eventTime: Date(),
            symbol: currencyPair,
            tradeID: 1,
            price: "123487",
            quantity: "0.323233",
            firstTradeID: 2,
            lastTradeID: 3,
            tradeTime: Date(timeIntervalSince1970: 1626009619),
            isBuyer: true
        )
        
        // When
        sut = MarketHistoryCellViewModel(
            aggregateData: aggregateData,
            currencyPair: currencyPair
        )
        
        // Then
        XCTAssertEqual(sut.formattedPrice, "123,487.00")
        XCTAssertEqual(sut.formattedQuantity, "0.323233")
        XCTAssertEqual(sut.formattedTradeTime, "20:20:19")
    }
    
    func testPlaceholderViewModelComputedProperties() {
        // When
        sut = PlacaholderMarketHistoryCellViewModel()
        
        // Then
        XCTAssertEqual(sut.formattedPrice, "--")
        XCTAssertEqual(sut.formattedQuantity, "--")
        XCTAssertEqual(sut.formattedTradeTime, "--")
    }
}
