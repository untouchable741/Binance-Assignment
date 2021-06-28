//
//  MockAPIServices.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import Foundation
import RxSwift
@testable import BinanceOrderBook

final class MockAPIServices: APIServices {
    private(set) var fetchDepthChartSnapshotCalledCount: Int = 0
    private(set) var fetchDepthChartSnapshotCurrencyPair: CurrencyPair?
    private(set) var fetchDepthChartSnapshotLimit: Int?
    var stubFetchDepthChartSnapshot: DepthChartResponseData!
    func fetchDepthChartSnapshot(currencyPair: CurrencyPair, limit: Int) -> Single<DepthChartResponseData> {
        fetchDepthChartSnapshotCalledCount += 1
        fetchDepthChartSnapshotCurrencyPair = currencyPair
        fetchDepthChartSnapshotLimit = limit
        return Single.just(stubFetchDepthChartSnapshot)
    }
    
    private(set) var fetchAggregateTradeDataCalledCount: Int = 0
    private(set) var fetchAggregateTradeDataCurrencyPair: CurrencyPair?
    private(set) var fetchAggregateTradeDataLimit: Int?
    var stubFetchAggregateTradeData: [AggregateTradeData]!
    func fetchAggregateTradeData(currencyPair: CurrencyPair, limit: Int) -> Single<[AggregateTradeData]> {
        fetchAggregateTradeDataCalledCount += 1
        fetchAggregateTradeDataCurrencyPair = currencyPair
        fetchAggregateTradeDataLimit = limit
        return Single.just(stubFetchAggregateTradeData)
    }
}
