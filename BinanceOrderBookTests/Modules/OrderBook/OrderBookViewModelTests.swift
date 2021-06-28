//
//  OrderBookViewModelTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
import RxSwift
import RxBlocking
@testable import BinanceOrderBook

class OrderBookViewModelTests: XCTestCase {
    
    var mockInteractor: MockOrderBookInteractor!
    var sut: OrderBookViewModelProtocol!
    
    override func setUp() {
        super.setUp()
        mockInteractor = MockOrderBookInteractor()
        sut = OrderBookViewModel(currencyPair: .BTCUSDT, interactor: mockInteractor)
    }
    
    override func tearDown() {
        mockInteractor = nil
        sut = nil
        super.tearDown()
    }
    
    func testLoadData_whenUpdatedLocalSnapshotNotNil() throws {
        // Given
        mockInteractor.stubGetDepthData = Single<DepthChartResponseData>.just(.mock())
        /// Because we use skil(until:), we need to delay socketData for 0.5s
        mockInteractor.stubSubscribeStreamDepthChartSocketData = Observable.just(.mock()).delay(.milliseconds(500), scheduler: MainScheduler.instance)
        mockInteractor.stubUpdatedLocalSnapshot = DepthChartResponseData(
            lastUpdateId: 999,
            bids: [PriceLevel(price: 1826738.223, quantity: 0.32345)],
            asks: [PriceLevel(price: 18723.23, quantity: 84.3)]
        )
        
        // When
        sut.loadData()
        
        // Then
        let results = try! sut.viewModelStateObservable.take(2).toBlocking(timeout: 1).toArray()
        let cellViewModels = try! sut.cellViewModelsDriver.toBlocking().first()
        XCTAssertEqual(results, [
            .loading("Loading order book data"),
            .finishedLoadData
        ])
        XCTAssertEqual(cellViewModels?.count, 25)
        let firstCellViewModel = try XCTUnwrap(cellViewModels?.first)
        XCTAssertEqual(firstCellViewModel.formattedBidPrice, "1.826.738,22")
        XCTAssertEqual(firstCellViewModel.formattedBidQuantity, "0,323450")
        XCTAssertEqual(firstCellViewModel.formattedAskPrice, "18.723,23")
        XCTAssertEqual(firstCellViewModel.formattedAskQuantity, "84,300000")
        XCTAssertEqual(firstCellViewModel.bidQuantityPercentage, 1)
        XCTAssertEqual(firstCellViewModel.askQuantityPercentage, 1)
        for i in 1..<(cellViewModels?.count ?? 0) {
            XCTAssertEqual(cellViewModels?[i].formattedBidPrice, "--")
            XCTAssertEqual(cellViewModels?[i].formattedBidQuantity, "--")
            XCTAssertEqual(cellViewModels?[i].formattedAskPrice, "--")
            XCTAssertEqual(cellViewModels?[i].formattedAskQuantity, "--")
            XCTAssertEqual(cellViewModels?[i].bidQuantityPercentage, 0)
            XCTAssertEqual(cellViewModels?[i].askQuantityPercentage, 0)
        }
    }
    
    func testLoadData_whenUpdatedLocalSnapshotIsNil() {
        // Given
        mockInteractor.stubGetDepthData = Single<DepthChartResponseData>.just(.mock())
        /// Because we use skil(until:), we need to delay socketData for 0.5s
        mockInteractor.stubSubscribeStreamDepthChartSocketData = Observable.just(.mock()).delay(.milliseconds(500), scheduler: MainScheduler.instance)
        mockInteractor.stubUpdatedLocalSnapshot = nil
        
        // When
        sut.loadData()
        
        // Then
        let results = try! sut.viewModelStateObservable.take(2).toBlocking(timeout: 1).toArray()
        let cellViewModels = try! sut.cellViewModelsDriver.toBlocking().first()
        XCTAssertEqual(results, [
            .loading("Loading order book data"),
            .loading("Data corrupted, re-fetching data")
        ])
        XCTAssertEqual(cellViewModels?.count, 25)
    }
}
