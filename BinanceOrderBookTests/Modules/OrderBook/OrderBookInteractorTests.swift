//
//  OrderBookInteractorTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
@testable import BinanceOrderBook

final class OrderBookInteractorTests: XCTestCase {
    
    var mockAPIServices: MockAPIServices!
    var mockSocketServices: MockSocketProvider!
    var sut: OrderBookInteractor!
    
    override func setUp() {
        super.setUp()
        mockAPIServices = MockAPIServices()
        mockSocketServices = MockSocketProvider()
        sut = OrderBookInteractor(apiServices: mockAPIServices, socketService: mockSocketServices)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testSubscribeStream() throws {
        // Given
        let expectation = expectation(description: #function)
        let currencyPair = CurrencyPair.BTCUSDT
        let date = Date()
        var result: DepthChartSocketResponse?
        mockSocketServices.stubSubscribeResponse = DepthChartSocketResponse(
            eventType: "event_type",
            eventTime: date,
            symbol: currencyPair,
            firstUpdateID: 1,
            finalUpdateID: 2,
            bids: [PriceLevel(price: 1, quantity: 2)],
            asks: [PriceLevel(price: 3, quantity: 4)]
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
        XCTAssertEqual(mockSocketServices.subscribeStreamNames, [currencyPair.depthStream])
        let depthChartData = try XCTUnwrap(result)
        XCTAssertEqual(depthChartData.eventType, "event_type")
        XCTAssertEqual(depthChartData.eventTime, date)
        XCTAssertEqual(depthChartData.symbol, .BTCUSDT)
        XCTAssertEqual(depthChartData.firstUpdateID, 1)
        XCTAssertEqual(depthChartData.finalUpdateID, 2)
        XCTAssertEqual(depthChartData.bids.count, 1)
        XCTAssertEqual(depthChartData.bids.first?.price, 1)
        XCTAssertEqual(depthChartData.bids.first?.quantity, 2)
        XCTAssertEqual(depthChartData.asks.count, 1)
        XCTAssertEqual(depthChartData.asks.first?.price, 3)
        XCTAssertEqual(depthChartData.asks.first?.quantity, 4)
    }
    
    func testUnsubscribeStream() {
        // Given
        let currencyPair = CurrencyPair.BTCUSDT
        
        // When
        try? sut.unsubscribeStream(currencyPair: currencyPair)
        
        // Then
        XCTAssertEqual(mockSocketServices.unsubscribeCalledCount, 1)
        XCTAssertEqual(mockSocketServices.unsubscribeStreamNames, [currencyPair.depthStream])
    }
    
    func testGetDepthData() throws {
        // Given
        let expectation = expectation(description: #function)
        let currencyPair = CurrencyPair.BTCUSDT
        var result: DepthChartResponseData?
        mockAPIServices.stubFetchDepthChartSnapshot = DepthChartResponseData(
            lastUpdateId: 1,
            bids: [PriceLevel(price: 1, quantity: 2)],
            asks: [PriceLevel(price: 3, quantity: 4)]
        )
        
        // When
        let disposable = sut
            .getDepthData(currencyPair: currencyPair)
            .subscribe(
                onSuccess: { response in
                    result = response
                    expectation.fulfill()
                })
        
        // Then
        waitForExpectations(timeout: 0.1) { _ in
            disposable.dispose()
        }
        XCTAssertEqual(mockAPIServices.fetchDepthChartSnapshotCalledCount, 1)
        XCTAssertEqual(mockAPIServices.fetchDepthChartSnapshotCurrencyPair, currencyPair)
        XCTAssertEqual(mockAPIServices.fetchDepthChartSnapshotLimit, 25)
        let depthChartData = try XCTUnwrap(result)
        XCTAssertEqual(depthChartData.lastUpdateId, 1)
        XCTAssertEqual(depthChartData.bids.count, 1)
        XCTAssertEqual(depthChartData.bids.first?.price, 1)
        XCTAssertEqual(depthChartData.bids.first?.quantity, 2)
        XCTAssertEqual(depthChartData.asks.count, 1)
        XCTAssertEqual(depthChartData.asks.first?.price, 3)
        XCTAssertEqual(depthChartData.asks.first?.quantity, 4)
    }
    
    func testUpdateLocalSnapshot_whenSocketDataIsOutdated_shouldReturnLocalSnapshot() {
        // Given
        // socketDataFinalUpdateId < snapshotLastUpdateId
        let socketDataFinalUpdateId = 1111
        let snapshotLastUpdateId = 2222
        
        let snapshot = DepthChartResponseData(
            lastUpdateId: snapshotLastUpdateId,
            bids: [
                PriceLevel(price: 1000, quantity: 2)
            ],
            asks: [
                PriceLevel(price: 1000, quantity: 4)
            ])
        let socketData = DepthChartSocketResponse(
            eventType: "mock",
            eventTime: Date(),
            symbol: .BTCUSDT,
            firstUpdateID: 1,
            finalUpdateID: socketDataFinalUpdateId,
            bids: [
                PriceLevel(price: 1000, quantity: 2)
            ],
            asks: [
                PriceLevel(price: 1000, quantity: 2)
            ]
        )
        
        // When
        let updatedSnapshot = sut.updateLocalSnapshot(snapshot, with: socketData)
        
        // Then
        XCTAssertEqual(updatedSnapshot?.lastUpdateId, snapshot.lastUpdateId)
        XCTAssertEqual(updatedSnapshot?.bids.count, snapshot.bids.count)
        XCTAssertEqual(updatedSnapshot?.bids.first?.price, snapshot.bids.first?.price)
        XCTAssertEqual(updatedSnapshot?.bids.first?.quantity, snapshot.bids.first?.quantity)
        XCTAssertEqual(updatedSnapshot?.asks.count, snapshot.asks.count)
        XCTAssertEqual(updatedSnapshot?.asks.first?.price, snapshot.asks.first?.price)
        XCTAssertEqual(updatedSnapshot?.asks.first?.quantity, snapshot.asks.first?.quantity)
    }
    
    func testUpdateLocalSnapshot_whenInsertingNewPriceLevels() {
        // Given
        // socketDataFinalUpdateId > snapshotLastUpdateId
        let socketDataFinalUpdateId = 2
        let snapshotLastUpdateId = 1
        
        let snapshot = DepthChartResponseData(
            lastUpdateId: snapshotLastUpdateId,
            bids: [
                PriceLevel(price: 1000, quantity: 2),
                PriceLevel(price: 995, quantity: 2)
            ],
            asks: [
                PriceLevel(price: 1100, quantity: 4),
                PriceLevel(price: 1120, quantity: 4)
            ])
        let socketData = DepthChartSocketResponse(
            eventType: "mock",
            eventTime: Date(),
            symbol: .BTCUSDT,
            firstUpdateID: 1,
            finalUpdateID: socketDataFinalUpdateId,
            bids: [
                PriceLevel(price: 1010, quantity: 2),
                PriceLevel(price: 996, quantity: 2)
            ],
            asks: [
                PriceLevel(price: 1090, quantity: 2),
                PriceLevel(price: 1110, quantity: 2)
            ]
        )
        
        // When
        let updatedSnapshot = sut.updateLocalSnapshot(snapshot, with: socketData)
        
        // Then
        XCTAssertEqual(updatedSnapshot?.lastUpdateId, socketDataFinalUpdateId)
        XCTAssertEqual(updatedSnapshot?.bids.count, 4)
        XCTAssertEqual(updatedSnapshot?.bids[0].price, 1010)
        XCTAssertEqual(updatedSnapshot?.bids[0].quantity, 2)
        XCTAssertEqual(updatedSnapshot?.bids[1].price, 1000)
        XCTAssertEqual(updatedSnapshot?.bids[1].quantity, 2)
        XCTAssertEqual(updatedSnapshot?.bids[2].price, 996)
        XCTAssertEqual(updatedSnapshot?.bids[2].quantity, 2)
        XCTAssertEqual(updatedSnapshot?.bids[3].price, 995)
        XCTAssertEqual(updatedSnapshot?.bids[3].quantity, 2)
        XCTAssertEqual(updatedSnapshot?.asks.count, 4)
        XCTAssertEqual(updatedSnapshot?.asks[0].price, 1090)
        XCTAssertEqual(updatedSnapshot?.asks[0].quantity, 2)
        XCTAssertEqual(updatedSnapshot?.asks[1].price, 1100)
        XCTAssertEqual(updatedSnapshot?.asks[1].quantity, 4)
        XCTAssertEqual(updatedSnapshot?.asks[2].price, 1110)
        XCTAssertEqual(updatedSnapshot?.asks[2].quantity, 2)
        XCTAssertEqual(updatedSnapshot?.asks[3].price, 1120)
        XCTAssertEqual(updatedSnapshot?.asks[3].quantity, 4)
    }
    
    func testUpdateLocalSnapshot_whenDeleteExistingPriceLevels() {
        // Given
        // socketDataFinalUpdateId > snapshotLastUpdateId
        let socketDataFinalUpdateId = 2
        let snapshotLastUpdateId = 1
        
        let snapshot = DepthChartResponseData(
            lastUpdateId: snapshotLastUpdateId,
            bids: [
                PriceLevel(price: 1000, quantity: 2),
                PriceLevel(price: 995, quantity: 2)
            ],
            asks: [
                PriceLevel(price: 1100, quantity: 4),
                PriceLevel(price: 1120, quantity: 4)
            ])
        let socketData = DepthChartSocketResponse(
            eventType: "mock",
            eventTime: Date(),
            symbol: .BTCUSDT,
            firstUpdateID: 1,
            finalUpdateID: socketDataFinalUpdateId,
            bids: [
                PriceLevel(price: 1010, quantity: 2),
                PriceLevel(price: 995, quantity: 0)
            ],
            asks: [
                PriceLevel(price: 1100, quantity: 0),
                PriceLevel(price: 1110, quantity: 2)
            ]
        )
        
        // When
        let updatedSnapshot = sut.updateLocalSnapshot(snapshot, with: socketData)
        
        // Then
        XCTAssertEqual(updatedSnapshot?.lastUpdateId, socketDataFinalUpdateId)
        XCTAssertEqual(updatedSnapshot?.bids.count, 2)
        XCTAssertEqual(updatedSnapshot?.bids[0].price, 1010)
        XCTAssertEqual(updatedSnapshot?.bids[0].quantity, 2)
        XCTAssertEqual(updatedSnapshot?.bids[1].price, 1000)
        XCTAssertEqual(updatedSnapshot?.bids[1].quantity, 2)
        XCTAssertEqual(updatedSnapshot?.asks.count, 2)
        XCTAssertEqual(updatedSnapshot?.asks[0].price, 1110)
        XCTAssertEqual(updatedSnapshot?.asks[0].quantity, 2)
        XCTAssertEqual(updatedSnapshot?.asks[1].price, 1120)
        XCTAssertEqual(updatedSnapshot?.asks[1].quantity, 4)
    }
}
