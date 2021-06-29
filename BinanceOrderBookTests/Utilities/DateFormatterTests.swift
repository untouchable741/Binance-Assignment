//
//  DateFormatterTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
@testable import BinanceOrderBook

final class DateFormatterTests: XCTestCase {
    var sut: DateFormatter!
    
    override func setUp() {
        super.setUp()
        sut = DateFormatter.sharedDateFormatter
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testSharedFormatter() {
        XCTAssertEqual(sut.timeZone, TimeZone.current)
    }
    
    func testTimeString_whenHourLessThan12() {
        // When
        let givenDate = Date(timeIntervalSince1970: 1624849619)
        sut.timeZone = TimeZone(identifier: "Asia/Bangkok")
        
        // When
        let timeString = sut.timeString(from: givenDate)
        
        // Then
        XCTAssertEqual(timeString, "10:06:59")
    }
    
    func testTimeString_whenHourGreaterThan12() {
        // When
        let givenDate = Date(timeIntervalSince1970: 1626009619)
        sut.timeZone = TimeZone(identifier: "Asia/Bangkok")
        
        // When
        let timeString = sut.timeString(from: givenDate)
        
        // Then
        XCTAssertEqual(timeString, "20:20:19")
    }
}
