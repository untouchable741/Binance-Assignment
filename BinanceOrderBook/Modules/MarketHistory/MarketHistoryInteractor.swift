//
//  MarketHistoryInteractor.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import Foundation
import RxSwift

protocol MarketHistoryInteractorProtocol {
    func subscribeStream(currencyPair: CurrencyPair) -> Observable<AggregateTradeData>
    func getAggregateTradeData(currencyPair: CurrencyPair) -> Single<[AggregateTradeData]>
}

class MarketHistoryInteractor: MarketHistoryInteractorProtocol {
    
    private let apiServices: APIServices
    private let socketService: SocketDataProvider
    private let disposeBag = DisposeBag()
    
    init(
        apiServices: APIServices = APIClient(),
        socketService: SocketDataProvider = SocketManager.shared
    ) {
        self.apiServices = apiServices
        self.socketService = socketService
    }
    
    func subscribeStream(currencyPair: CurrencyPair) -> Observable<AggregateTradeData> {
        return socketService.subscribe(streamName: [currencyPair.aggregateTrade])
    }
    
    func getAggregateTradeData(currencyPair: CurrencyPair) -> Single<[AggregateTradeData]> {
        return apiServices.fetchAggregateTradeData(currencyPair: currencyPair, limit: AppConfiguration.marketHistoryLimit)
    }
    
    
}
