//
//  CodableExtensionTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
@testable import BinanceOrderBook

struct MockCodable: Codable {
    var intValue: Int = 1
    var stringValue: String = "This is a string"
}

final class CodableExtensionTests: XCTestCase {
    
    func testJsonStringComputedProperty() {
        // Given
        let mockObject = MockCodable()
        
        // When
        let jsonString = mockObject.jsonString
        
        // Then
        XCTAssertEqual(
            jsonString,
            """
            {"intValue":1,"stringValue":"This is a string"}
            """
        )
    }
}
