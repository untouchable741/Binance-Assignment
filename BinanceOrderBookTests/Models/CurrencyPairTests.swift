//
//  CurrencyPairTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
@testable import BinanceOrderBook

final class CurrencyPairTests: XCTestCase {
    
    func testBTCUSDT() {
        // When
        let sut = CurrencyPair.BTCUSDT
        
        // Then
        XCTAssertEqual(sut.depthStream, "btcusdt@depth")
        XCTAssertEqual(sut.aggregateTrade, "btcusdt@aggTrade")
        XCTAssertEqual(sut.quantityFraction.min, 6)
        XCTAssertEqual(sut.quantityFraction.max, 6)
        XCTAssertEqual(sut.priceFraction.max, 2)
        XCTAssertEqual(sut.priceFraction.max, 2)
    }
}

