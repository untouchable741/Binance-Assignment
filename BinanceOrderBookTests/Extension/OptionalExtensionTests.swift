//
//  OptionalExtensionTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
@testable import BinanceOrderBook

final class OptionalExtensionTests: XCTestCase {

    func testIsNilComputedProperty() {
        // Test some primitive data types used in app
        var optionalInt: Int? = nil
        XCTAssertTrue(optionalInt.isNil)
        
        optionalInt = 9
        XCTAssertFalse(optionalInt.isNil)
        
        var optionalString: String? = nil
        XCTAssertTrue(optionalString.isNil)
        
        optionalString = "a string"
        XCTAssertFalse(optionalString.isNil)
        
        var optionalDecimal: Decimal? = nil
        XCTAssertTrue(optionalDecimal.isNil)
        
        optionalDecimal = 88
        XCTAssertFalse(optionalDecimal.isNil)
    }
}
