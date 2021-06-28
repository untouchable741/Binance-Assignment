//
//  CollectionExtensionTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
@testable import BinanceOrderBook

final class CollectionExtensionTests: XCTestCase {

    func testSafeSubscript() {
        // Given
        let array = [1, 2, 3, 4]
        
        // Then
        XCTAssertNil(array[safe: -1])
        XCTAssertEqual(array[safe: 0], 1)
        XCTAssertEqual(array[safe: 1], 2)
        XCTAssertEqual(array[safe: 2], 3)
        XCTAssertEqual(array[safe: 3], 4)
        XCTAssertNil(array[safe: 4])
    }
}
