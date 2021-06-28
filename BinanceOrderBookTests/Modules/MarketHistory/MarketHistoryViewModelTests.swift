//
//  MarketHistoryViewModelTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
import RxSwift
import RxBlocking
@testable import BinanceOrderBook

final class MarketHistoryViewModelTests: XCTestCase {

    var mockInteractor: MockMarketHistoryInteractor!
    var sut: MarketHistoryViewModelProtocol!
    
    override func setUp() {
        super.setUp()
        mockInteractor = MockMarketHistoryInteractor()
        sut = MarketHistoryViewModel(currencyPair: .BTCUSDT, interactor: mockInteractor)
    }
    
    override func tearDown() {
        mockInteractor = nil
        sut = nil
        super.tearDown()
    }
    
    func testLoadData_whenInsertHappened() {
        // Given
        let givenDate = Date()
        mockInteractor.stubGetAggregateTradeData = Single<[AggregateTradeData]>.just(
            [
            .mock(
                tradeTime: givenDate.addingTimeInterval(2)
            ),
             .mock(
                tradeTime: givenDate.addingTimeInterval(3)
             )
        ])
        mockInteractor.stubSubscribeStreamAggregateTradeData = Observable.just(
            .mock(
                price: "999.00",
                tradeTime: givenDate.addingTimeInterval(4)
            )
        )
        
        // When
        sut.loadData(isForcedRefresh: false)
        
        // Then
        let results = try! sut.viewModelStateObservable.take(2).toBlocking(timeout: 1).toArray()
        let cellViewModels = try! sut.cellViewModelsDriver.toBlocking().first()
        XCTAssertEqual(results, [
            .loading("Loading market history data"),
            .finishedLoadData
        ])
        XCTAssertEqual(cellViewModels?.count, 3)
        XCTAssertEqual(cellViewModels?.first?.formattedPrice, "999,00")
    }
    
    func testLoadData_whenNoInsertNotHappened() {
        // Given
        let givenDate = Date()
        mockInteractor.stubGetAggregateTradeData = Single<[AggregateTradeData]>.just(
            [
            .mock(
                price: "888.00",
                tradeTime: givenDate.addingTimeInterval(2)
            ),
             .mock(
                price: "777.00",
                tradeTime: givenDate.addingTimeInterval(3)
             )
        ])
        mockInteractor.stubSubscribeStreamAggregateTradeData = Observable.just(
            .mock(
                price: "999.00",
                tradeTime: givenDate.addingTimeInterval(1)
            )
        )
        
        // When
        sut.loadData(isForcedRefresh: false)
        
        // Then
        let results = try! sut.viewModelStateObservable.take(2).toBlocking(timeout: 1).toArray()
        let cellViewModels = try! sut.cellViewModelsDriver.toBlocking().first()
        XCTAssertEqual(results, [
            .loading("Loading market history data"),
            .finishedLoadData
        ])
        XCTAssertEqual(cellViewModels?.count, 2)
        XCTAssertEqual(cellViewModels?.first?.formattedPrice, "777,00")
        XCTAssertEqual(cellViewModels?.last?.formattedPrice, "888,00")
    }
}
