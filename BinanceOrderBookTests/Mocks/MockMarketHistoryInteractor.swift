//
//  MockMarketHistoryInteractor.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import Foundation
import RxSwift
@testable import BinanceOrderBook

final class MockMarketHistoryInteractor: MarketHistoryInteractorProtocol {
    private(set) var subscribeStreamCalledCount: Int = 0
    private(set) var subscribeStreamCurrencyPair: CurrencyPair?
    var stubSubscribeStreamAggregateTradeData: Observable<AggregateTradeData>?
    func subscribeStream(currencyPair: CurrencyPair) -> Observable<AggregateTradeData> {
        subscribeStreamCalledCount += 1
        subscribeStreamCurrencyPair = currencyPair
        return stubSubscribeStreamAggregateTradeData!
    }
    
    private(set) var unsubscribeStreamCalledCount: Int = 0
    private(set) var unsubscribeStreamCurrencyPair: CurrencyPair?
    func unsubscribeStream(currencyPair: CurrencyPair) throws {
        unsubscribeStreamCalledCount += 1
        unsubscribeStreamCurrencyPair = currencyPair
    }
    
    private(set) var getAggregateTradeDataCalledCount: Int = 0
    private(set) var getAggregateTradeDataCurrencyPair: CurrencyPair?
    var stubGetAggregateTradeData: Single<[AggregateTradeData]>!
    func getAggregateTradeData(currencyPair: CurrencyPair) -> Single<[AggregateTradeData]> {
        getAggregateTradeDataCalledCount += 1
        getAggregateTradeDataCurrencyPair = currencyPair
        return stubGetAggregateTradeData
    }
}
