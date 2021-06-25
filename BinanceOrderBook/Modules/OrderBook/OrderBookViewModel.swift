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
    var numberOfOrders: Int { get }
    func cellViewModel(at index: Int) -> OrderBookCellViewModel?
    func loadData()
}

final class OrderBookViewModel: OrderBookViewModelProtocol {
    
    // Store properties
    
    private let currencyPair: CurrencyPair
    private let interactor: OrderBookInteractorProtocol
    @ThreadSafety(value: makeDefaultCellViewModels())
    private var orderBookCellViewModels: [OrderBookCellViewModel] {
        didSet {
            viewModelStateRelay.accept(.loadedData)
        }
    }
    
    var maxDepthQuantity: NSDecimalNumber?
    
    // Relays
    
    private let disposedBag = DisposeBag()
    private let snapshotRelay = BehaviorRelay<DepthChartResponseData?>(value: nil)
    private let socketRelay = BehaviorRelay<DepthChartSocketResponse?>(value: nil)
    
    // RxViewModel properties
    
    private let viewModelStateRelay = BehaviorRelay<RxViewModelState>(value: .initial)
    
    init(
        currencyPair: CurrencyPair = .BTCUSDT,
        interactor: OrderBookInteractorProtocol = OrderBookInteractor()
    ) {
        self.currencyPair = currencyPair
        self.interactor = interactor
    }
    
    func loadData() {
        let socketStreamObservable = interactor.subscribeStream(currencyPair: .BTCUSDT)
        let snapshotObservable = interactor.getDepthData(currencyPair: .BTCUSDT)
        
        // Firstly subscribe to socket stream
        socketStreamObservable
            .bind(to: socketRelay)
            .disposed(by: disposedBag)
        
        // Fetch DepthChart Snapshot but make sure snapshot wont fired until first socket stream is fired
        snapshotObservable
            .asObservable()
            .take(until: socketStreamObservable)
            .bind(to: snapshotRelay)
            .disposed(by: disposedBag)
        
        // Combine latest both and ignore if either of them is nil
        // Ignore initial nil value of snapshot and take 1 to get only the first value from api callback
        // The subsequent value will be updated manually after each merge completed and should not trigger combine latest.
        Observable.combineLatest(
            snapshotRelay.filter { $0 != nil }.take(1),
            socketRelay
        )
        .filter({ $0.0 != nil && $0.1 != nil })
        .bind(onNext: { [weak self] snapshotData, socketData in
            guard let snapshotData = snapshotData, let socketData = socketData else {
                return
            }
            if let mergedLocalOrderBook = self?.interactor.merge(snapshot: snapshotData, socketData: socketData) {
                let totalBidQuantity = mergedLocalOrderBook.bids.reduce(0, { $0 + $1.quantity })
                let totalAskQuantity = mergedLocalOrderBook.asks.reduce(0, { $0 + $1.quantity })
                var accumulateTotalBid: Decimal = 0
                var accumulateTotalAsk: Decimal = 0
                self?.orderBookCellViewModels = (0..<25).map { i in
                    accumulateTotalBid += mergedLocalOrderBook.bids[i].quantity
                    accumulateTotalAsk += mergedLocalOrderBook.asks[i].quantity
                    return OrderBookCellViewModel(
                        bidPriceLevel: mergedLocalOrderBook.bids[i],
                        askPriceLevel: mergedLocalOrderBook.asks[i],
                        bidQuantityPercentage: accumulateTotalBid / totalBidQuantity,
                        askQuantityPercentage: accumulateTotalAsk / totalAskQuantity,
                        currencyPair: .BTCUSDT
                    )
                }
            }
        })
        .disposed(by: disposedBag)
    }
    
    static func makeDefaultCellViewModels() -> [OrderBookCellViewModel] {
        return (0..<25).map { i in
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


// MARK: - RxViewModel conformance

extension OrderBookViewModel {
    var viewModelStateObservable: Observable<RxViewModelState> {
        return viewModelStateRelay.asObservable()
    }
}

// MARK: - DataSource

extension OrderBookViewModel {
    var numberOfOrders: Int {
        return orderBookCellViewModels.count
    }
    
    func cellViewModel(at index: Int) -> OrderBookCellViewModel? {
        return orderBookCellViewModels[index]
    }
}
