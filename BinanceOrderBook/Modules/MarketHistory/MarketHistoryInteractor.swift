//
//  MarketHistoryInteractor.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import Foundation
import RxSwift

protocol MarketHistoryInteractorProtocol {
    var isSocketConnected: Bool { get }
    func subscribeStream(currencyPair: CurrencyPair) -> Observable<AggregateTradeData>
    func unsubscribeStream(currencyPair: CurrencyPair) throws
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
    
    var isSocketConnected: Bool {
        return socketService.isSocketConnected
    }
    
    func subscribeStream(currencyPair: CurrencyPair) -> Observable<AggregateTradeData> {
        return socketService.subscribe(streamNames: [currencyPair.aggregateTrade])
    }
    
    func unsubscribeStream(currencyPair: CurrencyPair) throws {
        return try socketService.unsubscribe(streamNames: [currencyPair.aggregateTrade])
    }
    
    func getAggregateTradeData(currencyPair: CurrencyPair) -> Single<[AggregateTradeData]> {
        return apiServices.fetchAggregateTradeData(currencyPair: currencyPair, limit: AppConfiguration.marketHistoryLimit)
    }
    
    
}
