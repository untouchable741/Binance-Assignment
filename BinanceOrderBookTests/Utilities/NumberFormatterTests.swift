//
//  NumberFormatterTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
@testable import BinanceOrderBook

final class NumberFormatterTests: XCTestCase {

    var sut: NumberFormatter!
    
    override func setUp() {
        super.setUp()
        sut = NumberFormatter.sharedNumberFormatter
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testSharedFormatter() {
        // When
        XCTAssertEqual(sut.numberStyle, .decimal)
        XCTAssertEqual(sut.groupingSeparator, ".")
        XCTAssertEqual(sut.decimalSeparator, ",")
    }
    
    func testQuantityString() {
        // Given
        let number = Decimal(0.418823223232323)
        let currencyPair = CurrencyPair.BTCUSDT
        
        // When
        let quantityString = sut.quantityString(from: number as NSDecimalNumber, of: currencyPair)
        
        // Then
        XCTAssertEqual(quantityString, "0,418823")
    }
    
    func testPriceString() {
        // Given
        let number = Decimal(33245.872892)
        let currencyPair = CurrencyPair.BTCUSDT
        
        // When
        let priceString = sut.priceString(from: number as NSDecimalNumber, of: currencyPair)
        
        // Then
        XCTAssertEqual(priceString, "33.245,87")
    }

}
