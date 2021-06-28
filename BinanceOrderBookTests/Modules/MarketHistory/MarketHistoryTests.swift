//
//  MarketHistoryTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
@testable import BinanceOrderBook

final class MarketHistoryTests: XCTestCase {

    var mockAPIServices: MockAPIServices!
    var mockSocketServices: MockSocketProvider!
    var sut: MarketHistoryInteractor!
    
    override func setUp() {
        super.setUp()
        mockAPIServices = MockAPIServices()
        mockSocketServices = MockSocketProvider()
        sut = MarketHistoryInteractor(apiServices: mockAPIServices, socketService: mockSocketServices)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testSubscribeStream() throws {
        // Given
        let expectation = expectation(description: #function)
        let currencyPair = CurrencyPair.BTCUSDT
        let eventTime = Date()
        let tradeTime = eventTime.addingTimeInterval(10)
        var result: AggregateTradeData?
        mockSocketServices.stubSubscribeResponse = AggregateTradeData(
            eventType: "event_type",
            eventTime: eventTime,
            symbol: currencyPair,
            tradeID: 1,
            price: "price",
            quantity: "quantity",
            firstTradeID: 2,
            lastTradeID: 3,
            tradeTime: tradeTime,
            isBuyer: true
        )
        
        // When
        let disposable = sut
            .subscribeStream(currencyPair: .BTCUSDT)
            .subscribe(onNext: { response in
            result = response
            expectation.fulfill()
        })
        
        // Then
        waitForExpectations(timeout: 0.1) { _ in
            disposable.dispose()
        }
        XCTAssertEqual(mockSocketServices.subscribeCalledCount, 1)
        XCTAssertEqual(mockSocketServices.subscribeStreamNames, [currencyPair.aggregateTrade])
        let aggregateTradeItem = try XCTUnwrap(result)
        XCTAssertEqual(aggregateTradeItem.eventType, "event_type")
        XCTAssertEqual(aggregateTradeItem.eventTime, eventTime)
        XCTAssertEqual(aggregateTradeItem.symbol, .BTCUSDT)
        XCTAssertEqual(aggregateTradeItem.tradeID, 1)
        XCTAssertEqual(aggregateTradeItem.price, "price")
        XCTAssertEqual(aggregateTradeItem.quantity, "quantity")
        XCTAssertEqual(aggregateTradeItem.firstTradeID, 2)
        XCTAssertEqual(aggregateTradeItem.lastTradeID, 3)
        XCTAssertEqual(aggregateTradeItem.tradeTime, tradeTime)
        XCTAssertEqual(aggregateTradeItem.isBuyer, true)
    }
    
    func testUnsubscribeStream() {
        // Given
        let currencyPair = CurrencyPair.BTCUSDT
        
        // When
        try? sut.unsubscribeStream(currencyPair: currencyPair)
        
        // Then
        XCTAssertEqual(mockSocketServices.unsubscribeCalledCount, 1)
        XCTAssertEqual(mockSocketServices.unsubscribeStreamNames, [currencyPair.aggregateTrade])
    }
    
    func testGetAggregateTradeData() throws {
        // Given
        let expectation = expectation(description: #function)
        let currencyPair = CurrencyPair.BTCUSDT
        let eventTime = Date()
        let tradeTime = eventTime.addingTimeInterval(10)
        var result: [AggregateTradeData]?
        mockAPIServices.stubFetchAggregateTradeData = [
            AggregateTradeData(
                eventType: "event_type",
                eventTime: eventTime,
                symbol: currencyPair,
                tradeID: 1,
                price: "price",
                quantity: "quantity",
                firstTradeID: 2,
                lastTradeID: 3,
                tradeTime: tradeTime,
                isBuyer: true
            )
        ]
        
        // When
        let disposable = sut
            .getAggregateTradeData(currencyPair: currencyPair)
            .subscribe(
                onSuccess: { response in
                    result = response
                    expectation.fulfill()
                })
        
        // Then
        waitForExpectations(timeout: 0.1) { _ in
            disposable.dispose()
        }
        XCTAssertEqual(mockAPIServices.fetchAggregateTradeDataCalledCount, 1)
        XCTAssertEqual(mockAPIServices.fetchAggregateTradeDataCurrencyPair, currencyPair)
        XCTAssertEqual(mockAPIServices.fetchAggregateTradeDataLimit, 80)
        XCTAssertEqual(result?.count, 1)
        let aggregateTradeItem = try XCTUnwrap(result?.first)
        XCTAssertEqual(aggregateTradeItem.eventType, "event_type")
        XCTAssertEqual(aggregateTradeItem.eventTime, eventTime)
        XCTAssertEqual(aggregateTradeItem.symbol, .BTCUSDT)
        XCTAssertEqual(aggregateTradeItem.tradeID, 1)
        XCTAssertEqual(aggregateTradeItem.price, "price")
        XCTAssertEqual(aggregateTradeItem.quantity, "quantity")
        XCTAssertEqual(aggregateTradeItem.firstTradeID, 2)
        XCTAssertEqual(aggregateTradeItem.lastTradeID, 3)
        XCTAssertEqual(aggregateTradeItem.tradeTime, tradeTime)
        XCTAssertEqual(aggregateTradeItem.isBuyer, true)
    }
}
