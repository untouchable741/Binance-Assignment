//
//  MockOrderBookInteractor.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import Foundation
import RxSwift
@testable import BinanceOrderBook

final class MockOrderBookInteractor: OrderBookInteractorProtocol {
    var stubIsSocketConnected: Bool = false
    var isSocketConnected: Bool {
        return stubIsSocketConnected
    }
    
    private(set) var subscribeStreamCalledCount: Int = 0
    private(set) var subscribeStreamCurrencyPair: CurrencyPair?
    var stubSubscribeStreamDepthChartSocketData: Observable<DepthChartSocketResponse>?
    func subscribeStream(currencyPair: CurrencyPair) -> Observable<DepthChartSocketResponse> {
        subscribeStreamCalledCount += 1
        subscribeStreamCurrencyPair = currencyPair
        return stubSubscribeStreamDepthChartSocketData!
    }
    
    private(set) var unsubscribeStreamCalledCount: Int = 0
    private(set) var unsubscribeStreamCurrencyPair: CurrencyPair?
    func unsubscribeStream(currencyPair: CurrencyPair) throws {
        unsubscribeStreamCalledCount += 1
        unsubscribeStreamCurrencyPair = currencyPair
    }
    
    private(set) var getDepthDataCalledCount: Int = 0
    private(set) var getDepthDataCurrencyPair: CurrencyPair?
    var stubGetDepthData: Single<DepthChartResponseData>!
    func getDepthData(currencyPair: CurrencyPair) -> Single<DepthChartResponseData> {
        getDepthDataCalledCount += 1
        getDepthDataCurrencyPair = currencyPair
        return stubGetDepthData
    }
    
    private(set) var updateLocalSnapshotCalledCount: Int = 0
    private(set) var updateLocalSnapshotData: DepthChartResponseData?
    private(set) var updateLocalSnapshotSocketData: DepthChartSocketResponse?
    var stubUpdatedLocalSnapshot: DepthChartResponseData?
    func updateLocalSnapshot(_ snapshot: DepthChartResponseData, with socketData: DepthChartSocketResponse) -> DepthChartResponseData? {
        updateLocalSnapshotCalledCount += 1
        updateLocalSnapshotData = snapshot
        updateLocalSnapshotSocketData = socketData
        return stubUpdatedLocalSnapshot
    }
}
