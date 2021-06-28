//
//  OrderBookCellViewModelTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
@testable import BinanceOrderBook

final class OrderBookCellViewModelTests: XCTestCase {
    
    var sut: OrderBookCellViewModelProtocol!
    
    func testViewModelComputedProperties() {
        // Given
        let currencyPair = CurrencyPair.BTCUSDT
        
        // When
        sut = OrderBookCellViewModel(
            bidPriceLevel: PriceLevel(price: 12398.44, quantity: 0.2312),
            askPriceLevel: PriceLevel(price: 23135.2443123, quantity: 0.123125),
            bidQuantityPercentage: 0.5,
            askQuantityPercentage: 0.4,
            currencyPair: currencyPair
        )
        
        // Then
        XCTAssertEqual(sut.formattedBidPrice, "12.398,44")
        XCTAssertEqual(sut.formattedBidQuantity, "0,231200")
        XCTAssertEqual(sut.formattedAskPrice, "23.135,24")
        XCTAssertEqual(sut.formattedAskQuantity, "0,123125")
        XCTAssertEqual(sut.askQuantityPercentage, 0.4)
        XCTAssertEqual(sut.bidQuantityPercentage, 0.5)
    }
    
    func testPlaceholderViewModelComputedProperties() {
        // When
        sut = PlacaholderOrderBookCellViewModel()

        // Then
        XCTAssertEqual(sut.formattedBidPrice, "--")
        XCTAssertEqual(sut.formattedBidQuantity, "--")
        XCTAssertEqual(sut.formattedAskPrice, "--")
        XCTAssertEqual(sut.formattedAskQuantity, "--")
        XCTAssertEqual(sut.askQuantityPercentage, 0)
        XCTAssertEqual(sut.bidQuantityPercentage, 0)
    }
}
