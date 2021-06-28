//
//  APIServicesTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 27/06/2021.
//

import XCTest
import Mockingjay
@testable import BinanceOrderBook

final class APIServicesTests: XCTestCase {
    
    var sut: APIClient!
    
    override func setUp() {
        super.setUp()
        sut = APIClient()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    
    func testFetchDepChartSnapshotWithSuccessResponse() {
        // Given
        let expectation = expectation(description: #function)
        stub(http(.get, uri: "/api/v3/depth"), jsonData(StubLoader.load(fileName: "depth")))
        
        // When
        let disposes = sut
            .fetchDepthChartSnapshot(currencyPair: .BTCUSDT, limit: 50)
            .subscribe(onSuccess: { response in
                XCTAssertEqual(response.lastUpdateId, 12063146364)
                XCTAssertEqual(response.bids.count, 50)
                XCTAssertEqual(response.asks.count, 50)
                XCTAssertEqual(response.bids.first?.price, Decimal(string: "33050"))
                XCTAssertEqual(response.bids.first?.quantity, Decimal(string: "0.740444"))
                XCTAssertEqual(response.asks.first?.price, Decimal(string: "33050.01"))
                XCTAssertEqual(response.asks.first?.quantity, Decimal(string: "0.320605"))
                expectation.fulfill()
            })
        
        // Then
        waitForExpectations(timeout: 1) { _ in
            disposes.dispose()
        }
    }
    
    func testFetchDepChartSnapshotWithError() {
        // Given
        let expectation = expectation(description: #function)
        stub(http(.get, uri: "/api/v3/depth"), failure(NSError(domain: "domain", code: 400, userInfo: nil)))
        
        // When
        let disposes = sut
            .fetchDepthChartSnapshot(currencyPair: .BTCUSDT, limit: 50)
            .subscribe(onFailure: { error in
                let error = try! XCTUnwrap(error as NSError)
                XCTAssertEqual(error.domain, "domain")
                XCTAssertEqual(error.code, 400)
                expectation.fulfill()
            })
        
        // Then
        waitForExpectations(timeout: 1) { _ in
            disposes.dispose()
        }
    }
    
    func testFetchAggregateTradeDataWithSuccessResponse() {
        // Given
        let expectation = expectation(description: #function)
        stub(http(.get, uri: "/api/v3/aggTrades"), jsonData(StubLoader.load(fileName: "aggTrades")))
        
        // When
        let disposes = sut
            .fetchAggregateTradeData(currencyPair: .BTCUSDT, limit: 50)
            .subscribe(onSuccess: { response in
                XCTAssertEqual(response.count, 80)
                XCTAssertEqual(response.first?.tradeID, 828683256)
                XCTAssertEqual(response.first?.price, "32731.22000000")
                XCTAssertEqual(response.first?.quantity, "0.05000000")
                XCTAssertEqual(response.first?.firstTradeID, 935171932)
                XCTAssertEqual(response.first?.lastTradeID, 935171932)
                XCTAssertEqual(response.first?.tradeTime.timeIntervalSince1970, 1624818328.771)
                XCTAssertEqual(response.first?.isBuyer, false)
                expectation.fulfill()
            })
        
        // Then
        waitForExpectations(timeout: 1) { _ in
            disposes.dispose()
        }
    }
    
    func testFetchAggregateTradeDataError() {
        // Given
        let expectation = expectation(description: #function)
        stub(http(.get, uri: "/api/v3/aggTrades"), failure(NSError(domain: "domain", code: 400, userInfo: nil)))
        
        // When
        let disposes = sut
            .fetchAggregateTradeData(currencyPair: .BTCUSDT, limit: 50)
            .subscribe(onFailure: { error in
                let error = try! XCTUnwrap(error as NSError)
                XCTAssertEqual(error.domain, "domain")
                XCTAssertEqual(error.code, 400)
                expectation.fulfill()
            })
        
        // Then
        waitForExpectations(timeout: 1) { _ in
            disposes.dispose()
        }
    }
}
