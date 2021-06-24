//
//  OrderBookInteractor.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import Foundation
import RxSwift

protocol OrderBookInteractorProtocol {
    func subscribeStream(currencyPair: CurrencyPair) -> Observable<DepthChartSocketResponse>
    func getDepthData(currencyPair: CurrencyPair) -> Single<DepthChartResponseData>
    func merge(snapshot: DepthChartResponseData, socketData: DepthChartSocketResponse) -> DepthChartResponseData?
}

final class OrderBookInteractor: OrderBookInteractorProtocol {

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
    
    func subscribeStream(currencyPair: CurrencyPair) -> Observable<DepthChartSocketResponse> {
        return socketService.subscribe(streamName: [currencyPair.depthStream])
    }
    
    func getDepthData(currencyPair: CurrencyPair) -> Single<DepthChartResponseData> {
        return apiServices.fetchDepthChartSnapshot(currencyPair: currencyPair, limit: 50)
    }
}

// MARK: - Merge business logic
extension OrderBookInteractor {
    func merge(snapshot: DepthChartResponseData, socketData: DepthChartSocketResponse) -> DepthChartResponseData? {
        var asks = snapshot.asks
        // Merge ask
        for i in 0..<socketData.asks.count {
            var snapshotIndex = 0
            while snapshotIndex < asks.count && socketData.asks[i].price < asks[snapshotIndex].price {
                snapshotIndex += 1
            }
            if snapshotIndex >= 25 {
                break
            }
            if socketData.asks[i].price == asks[snapshotIndex].price {
                if socketData.asks[i].quantity == "0" {
                    asks.remove(at: snapshotIndex)
                } else {
                    asks[snapshotIndex] = socketData.asks[i]
                }
            } else {
                asks.insert(socketData.asks[i], at: snapshotIndex)
            }
        }
        
        // Merge bids
        var bids = snapshot.bids
        for i in 0..<socketData.bids.count {
            var snapshotIndex = 0
            while snapshotIndex < bids.count && socketData.bids[i].price > bids[snapshotIndex].price {
                snapshotIndex += 1
            }
            if snapshotIndex >= 25 {
                break
            }
            if socketData.bids[i].price == bids[snapshotIndex].price {
                if socketData.bids[i].quantity == "0" {
                    bids.remove(at: snapshotIndex)
                } else {
                    bids[snapshotIndex] = socketData.bids[i]
                }
            } else {
                bids.insert(socketData.bids[i], at: snapshotIndex)
            }
        }
        return DepthChartResponseData(
            lastUpdateId: socketData.finalUpdateID,
            bids: Array(bids.prefix(25)),
            asks: Array(asks.prefix(25))
        )
    }
}
