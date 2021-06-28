//
//  OrderBookInteractor.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import Foundation
import RxSwift

protocol OrderBookInteractorProtocol {
    var isSocketConnected: Bool { get }
    func subscribeStream(currencyPair: CurrencyPair) -> Observable<DepthChartSocketResponse>
    func unsubscribeStream(currencyPair: CurrencyPair) throws
    func getDepthData(currencyPair: CurrencyPair) -> Single<DepthChartResponseData>
    func updateLocalSnapshot(_ snapshot: DepthChartResponseData, with socketData: DepthChartSocketResponse) -> DepthChartResponseData?
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
        
    var isSocketConnected: Bool {
        return socketService.isSocketConnected
    }
    
    func subscribeStream(currencyPair: CurrencyPair) -> Observable<DepthChartSocketResponse> {
        return socketService
            .subscribe(streamNames: [currencyPair.depthStream])
    }
    
    func unsubscribeStream(currencyPair: CurrencyPair) throws {
        return try socketService.unsubscribe(streamNames: [currencyPair.depthStream])
    }
    
    func getDepthData(currencyPair: CurrencyPair) -> Single<DepthChartResponseData> {
        return apiServices
            .fetchDepthChartSnapshot(currencyPair: currencyPair, limit: AppConfiguration.orderBookDefaultRowsCount)
    }
}

// MARK: - Merge business logic
extension OrderBookInteractor {
    func updateLocalSnapshot(_ snapshot: DepthChartResponseData, with socketData: DepthChartSocketResponse) -> DepthChartResponseData? {
        print("****")
        print("Snapshot last update \(snapshot.lastUpdateId)")
        print("Socket  first update \(socketData.firstUpdateID)")
        print("Socket  last  update \(socketData.finalUpdateID)")
        print("****")
        
        // Drop event if socketData.finalUpdateID <= snapshot.lastUpdateId
        // It's mean data from socket somehow outdated (e.g: network reason)
        guard socketData.finalUpdateID > snapshot.lastUpdateId else {
            return snapshot
        }
        
        var asks = snapshot.asks
        // Updating asks data by looping through socketData.ask
        for i in 0..<socketData.asks.count {
            var snapshotIndex = 0
            // Until we found approriate index for current socketData.ask[i]
            while snapshotIndex < asks.count && socketData.asks[i].price > asks[snapshotIndex].price {
                snapshotIndex += 1
            }
            
            // If its index out of desired rowCounts, we don't need to process anymore
            if snapshotIndex >= AppConfiguration.orderBookDefaultRowsCount {
                break
            }
            
            // Make sure snapshotIndex still in bound of ask.count
            // If this socket data price is equal to local ask at snapshotIndex
            if snapshotIndex < asks.count && socketData.asks[i].price == asks[snapshotIndex].price {
                // If quantity is zero, then remove this price
                if socketData.asks[i].quantity == 0 {
                    asks.remove(at: snapshotIndex)
                } else {
                    // Otherwise, update it's information
                    asks[snapshotIndex] = socketData.asks[i]
                }
                // If socketData is valid quantity, we need to insert it into local ask at approriate index to maintain the orders
            } else if socketData.asks[i].quantity > 0 {
                asks.insert(socketData.asks[i], at: snapshotIndex)
            }
        }
        
        // Merge bids
        var bids = snapshot.bids
        for i in 0..<socketData.bids.count {
            var snapshotIndex = 0
            while snapshotIndex < bids.count && socketData.bids[i].price < bids[snapshotIndex].price {
                snapshotIndex += 1
            }
            if snapshotIndex >= AppConfiguration.orderBookDefaultRowsCount {
                break
            }
            if snapshotIndex < bids.count && socketData.bids[i].price == bids[snapshotIndex].price {
                if socketData.bids[i].quantity == 0 {
                    bids.remove(at: snapshotIndex)
                } else {
                    bids[snapshotIndex] = socketData.bids[i]
                }
            } else if socketData.bids[i].quantity > 0 {
                bids.insert(socketData.bids[i], at: snapshotIndex)
            }
        }
        
        if bids.first?.price ?? 0 >= asks.first?.price ?? 0 {
            return nil
        }
        
        return DepthChartResponseData(
            lastUpdateId: socketData.finalUpdateID,
            bids: Array(bids.prefix(AppConfiguration.orderBookDefaultRowsCount)),
            asks: Array(asks.prefix(AppConfiguration.orderBookDefaultRowsCount))
        )
    }
}
