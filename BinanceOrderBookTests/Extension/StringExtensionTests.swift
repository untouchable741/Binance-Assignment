//
//  StringExtensionTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
@testable import BinanceOrderBook

final class StringExtensionTests: XCTestCase {

    func testJsonObjectComputedProperty() {
        // Given
        let jsonString =
            """
            {"intValue":1,"stringValue":"This is a string"}
            """
        
        // When
        let object = jsonString.jsonObject
        
        // Then
        XCTAssertEqual(object?["intValue"] as? Int, 1)
        XCTAssertEqual(object?["stringValue"] as? String, "This is a string")
    }
}
