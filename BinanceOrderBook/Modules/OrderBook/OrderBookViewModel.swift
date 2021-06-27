//
//  OrderBookViewModel.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import Foundation
import RxSwift
import RxCocoa

protocol OrderBookViewModelProtocol: RxViewModel {
    // Binding
    var cellViewModelsDriver: Driver<[OrderBookCellViewModelProtocol]> { get }
    
    // Public method
    func loadData(isForcedRefresh: Bool)
}

final class OrderBookViewModel: OrderBookViewModelProtocol {
    // Store properties
    private let currencyPair: CurrencyPair
    private let interactor: OrderBookInteractorProtocol
    @ThreadSafety(value: generatePlaceholderViewModels())
    private var orderBookCellViewModels: [OrderBookCellViewModelProtocol] {
        didSet {
            cellViewModelsRelay.accept(orderBookCellViewModels)
            viewModelStateRelay.accept(.finishedLoadData)
        }
    }
    
    // Relays
    
    private var disposedBag = DisposeBag()
    private let snapshotRelay = BehaviorRelay<DepthChartResponseData?>(value: nil)
    private let socketRelay = BehaviorRelay<DepthChartSocketResponse?>(value: nil)
    private let cellViewModelsRelay = BehaviorRelay<[OrderBookCellViewModelProtocol]>(value: generatePlaceholderViewModels())
    
    // RxViewModel properties
    
    var viewModelStateRelay = BehaviorRelay<RxViewModelState>(value: .initial)
    
    init(
        currencyPair: CurrencyPair = .BTCUSDT,
        interactor: OrderBookInteractorProtocol = OrderBookInteractor()
    ) {
        self.currencyPair = currencyPair
        self.interactor = interactor
    }
    
    func loadData(isForcedRefresh: Bool) {
        // Clear old data if this is forcedRefresh
        if isForcedRefresh {
            orderBookCellViewModels = OrderBookViewModel.generatePlaceholderViewModels()
            // Disposed all previous disposables
            disposedBag = DisposeBag()
        }
        
        // Trigger update state
        update(newState: .loading("Loading order book data"))
        
        // Create observables to retrieve data
        let socketStreamObservable = interactor.subscribeStream(currencyPair: currencyPair)
        let snapshotObservable = interactor.getDepthData(currencyPair: currencyPair)
        
        // Firstly subscribe to socket stream and observe values
        socketStreamObservable
            .bind(to: socketRelay)
            .disposed(by: disposedBag)
        
        // Fetch DepthChart Snapshot from REST API
        snapshotObservable
            .asObservable()
            // According to documentation, make sure socket is connected and received data before firing snapshot REST API so we use take(until:)
            // https://github.com/binance/binance-spot-api-docs/blob/master/web-socket-streams.md#how-to-manage-a-local-order-book-correctly
            .take(until: socketStreamObservable)
            .bind(to: snapshotRelay)
            .disposed(by: disposedBag)
        
        // Combine latest both so data will periodly get updated with socket callback and the very first snapshot REST API data.
        Observable.combineLatest(
            // Take 1 because snapshot REST API is Single and should only fired once, subsequent fired should be ignores
            snapshotRelay.unwrap().take(1),
            // Convenient unwrap socket data so we don't need to check nil manually
            socketRelay.unwrap()
        )
        // Simulate network delay when forceRefreshing
        .delay(.seconds(isForcedRefresh ? 1 : 0), scheduler: ConcurrentMainScheduler.instance)
        .bind(onNext: { [weak self] snapshotData, socketData in
            guard let self = self else { return }
            // Forward snapshotData and socketData to Interactor for keeping local snapshot updated
            // https://github.com/binance/binance-spot-api-docs/blob/master/web-socket-streams.md#how-to-manage-a-local-order-book-correctly
            if let updatedLocalSnapshot = self.interactor.updateLocalSnapshot(snapshotData, with: socketData){
                let totalBidQuantity = updatedLocalSnapshot.bids.reduce(0, { $0 + $1.quantity })
                let totalAskQuantity = updatedLocalSnapshot.asks.reduce(0, { $0 + $1.quantity })
                var accumulateTotalBid: Decimal = 0
                var accumulateTotalAsk: Decimal = 0
                self.orderBookCellViewModels = (0..<AppConfiguration.orderBookDefaultRowsCount).map { i in
                    accumulateTotalBid += updatedLocalSnapshot.bids[i].quantity
                    accumulateTotalAsk += updatedLocalSnapshot.asks[i].quantity
                    return OrderBookCellViewModel(
                        bidPriceLevel: updatedLocalSnapshot.bids[i],
                        askPriceLevel: updatedLocalSnapshot.asks[i],
                        bidQuantityPercentage: accumulateTotalBid / totalBidQuantity,
                        askQuantityPercentage: accumulateTotalAsk / totalAskQuantity,
                        currencyPair: self.currencyPair
                    )
                }
                // Update latest localSnashot into relay but this time it won't trigger bind(onNex:) because we previously defined take(1)
                // Next bind(onNext:) should be triggered only when receive data from socket stream
                self.snapshotRelay.accept(updatedLocalSnapshot)
            } else {
                // Unconsistent error detected after trying to update localSnapshot
                // We will force refreshing here
                self.loadData(isForcedRefresh: true)
            }
        })
        .disposed(by: disposedBag)
    }
    
    static func generatePlaceholderViewModels() -> [OrderBookCellViewModelProtocol] {
        return (0..<AppConfiguration.orderBookDefaultRowsCount).map { i in
            return OrderBookCellViewModel(
                isPlaceholder: true,
                bidPriceLevel: PriceLevel(price: 0, quantity: 0),
                askPriceLevel: PriceLevel(price: 0, quantity: 0),
                bidQuantityPercentage: 0,
                askQuantityPercentage: 0,
                currencyPair: .BTCUSDT
            )
        }
    }
}

// MARK: - DataSource

extension OrderBookViewModel {
    var cellViewModelsDriver: Driver<[OrderBookCellViewModelProtocol]> {
        return cellViewModelsRelay.asDriver()
    }
}
