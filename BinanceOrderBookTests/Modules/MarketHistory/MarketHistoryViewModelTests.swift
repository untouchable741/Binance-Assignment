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
    
    func testLoadData_whenInsertionHappened() {
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
        ]).delay(.seconds(1), scheduler: ConcurrentMainScheduler.instance)
        mockInteractor.stubSubscribeStreamAggregateTradeData = Observable.just(
            .mock(
                price: "999.00",
                tradeTime: givenDate.addingTimeInterval(4)
            )
        ).delay(.seconds(1), scheduler: ConcurrentMainScheduler.instance)
        
        // When
        sut.loadData()
        
        // Then
        let results = try! sut.viewModelStateObservable.take(2).toBlocking(timeout: 2).toArray()
        let cellViewModels = try! sut.cellViewModelsDriver.toBlocking().first()
        XCTAssertEqual(results, [
            .loading("Loading MarketHistory data..."),
            .finishedLoadData
        ])
        XCTAssertEqual(cellViewModels?.count, 3)
        XCTAssertEqual(cellViewModels?.first?.formattedPrice, "999,00")
    }
    
    func testLoadData_whenInsertionNotHappened() {
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
        ]).delay(.seconds(1), scheduler: ConcurrentMainScheduler.instance)
        mockInteractor.stubSubscribeStreamAggregateTradeData = Observable.just(
            .mock(
                price: "999.00",
                tradeTime: givenDate.addingTimeInterval(1)
            )
        ).delay(.seconds(1), scheduler: ConcurrentMainScheduler.instance)
        
        // When
        sut.loadData()
        
        // Then
        let results = try! sut.viewModelStateObservable.take(2).toBlocking(timeout: 2).toArray()
        let cellViewModels = try! sut.cellViewModelsDriver.toBlocking().first()
        XCTAssertEqual(results, [
            .loading("Loading MarketHistory data..."),
            .finishedLoadData
        ])
        XCTAssertEqual(cellViewModels?.count, 2)
        XCTAssertEqual(cellViewModels?.first?.formattedPrice, "777,00")
        XCTAssertEqual(cellViewModels?.last?.formattedPrice, "888,00")
    }
    
    func testLoadData_whenGetAggregateTradeDataError() {
        // Given
        let givenDate = Date()
        mockInteractor.stubGetAggregateTradeData = Single<[AggregateTradeData]>.error(APIError.invalidRequest).delay(.milliseconds(500), scheduler: ConcurrentMainScheduler.instance)
        mockInteractor.stubSubscribeStreamAggregateTradeData = Observable.just(
            .mock(
                price: "999.00",
                tradeTime: givenDate.addingTimeInterval(1)
            )
        ).delay(.milliseconds(500), scheduler: ConcurrentMainScheduler.instance)
        
        // When
        sut.loadData()
        
        // Then
        let results = try! sut.viewModelStateObservable.take(1).toBlocking(timeout: 2).toArray()
        XCTAssertEqual(results, [
            .error(APIError.invalidRequest)
        ])
    }
    
    func testLoadData_whenSocketStreamError() {
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
        ]).delay(.seconds(1), scheduler: ConcurrentMainScheduler.instance)
        mockInteractor.stubSubscribeStreamAggregateTradeData = Observable.error(APIError.conversionFailure).delay(.seconds(1), scheduler: ConcurrentMainScheduler.instance)
        
        // When
        sut.loadData()
        
        // Then
        let results = try! sut.viewModelStateObservable.take(1).toBlocking(timeout: 2).toArray()
        XCTAssertEqual(results, [
            .error(APIError.conversionFailure)
        ])
    }
}
