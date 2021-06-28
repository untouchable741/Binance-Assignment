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
    enum ReloadReason {
        case initial
        case forcedRefresh
        case corruptedData
        
        var status: String? {
            switch self {
            case .initial:
                return "Loading order book data"
            case .corruptedData:
                return "Data corrupted, re-fetching data"
            case .forcedRefresh:
                return "Refreshing order book data"
            }
        }
    }
    
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
    private var localOrderBook: DepthChartResponseData?
    
    // Relays
    
    private var disposedBag = DisposeBag()
    private let socketRelay = BehaviorRelay<DepthChartSocketResponse?>(value: nil)
    private let cellViewModelsRelay = BehaviorRelay<[OrderBookCellViewModelProtocol]>(value: generatePlaceholderViewModels())
    
    // RxViewModel properties
    
    var viewModelStateRelay = BehaviorRelay<RxViewModelState>(value: .initial)
    
    deinit {
        try? interactor.unsubscribeStream(currencyPair: currencyPair)
    }
    
    init(
        currencyPair: CurrencyPair = .BTCUSDT,
        interactor: OrderBookInteractorProtocol = OrderBookInteractor()
    ) {
        self.currencyPair = currencyPair
        self.interactor = interactor
    }
    
    func prepareState(for reloadReason: ReloadReason) {
        switch reloadReason {
        case .corruptedData:
            // unsubscribe stream but dont need to dispose disposeBag as we need to keep the socketRelay alive
            try? interactor.unsubscribeStream(currencyPair: currencyPair)
        case .forcedRefresh:
            // unsubscribe stream but dont need to dispose disposeBag as we need to keep the socketRelay alive
            try? interactor.unsubscribeStream(currencyPair: currencyPair)
            // Update UI with placeholder model
            orderBookCellViewModels = Self.generatePlaceholderViewModels()
        case .initial:
            break
        }
    }
    
    func loadData(isForcedRefresh: Bool) {
        loadData(reloadReason: isForcedRefresh ? .forcedRefresh : .initial)
    }
    
    func loadData(reloadReason: ReloadReason) {
        // Clear old data if this is forcedRefresh
        prepareState(for: reloadReason)
        
        // Trigger update state
        update(newState: .loading(reloadReason.status))
        
        // Create observables to retrieve data
        let socketStreamObservable = interactor
            .subscribeStream(currencyPair: currencyPair)
        
        // Firstly subscribe to socket stream and observe values
        socketStreamObservable
            .bind(to: socketRelay)
            .disposed(by: disposedBag)
        
        // Fetch DepthChart Snapshot from REST API
        // According to documentation, make sure socket is connected and received data before firing snapshot REST API so we use take(until:)
        // https://github.com/binance/binance-spot-api-docs/blob/master/web-socket-streams.md#how-to-manage-a-local-order-book-correctly
        let snapshotObservable = interactor
            .getDepthData(currencyPair: currencyPair)
            .asObservable()
            .take(until: socketStreamObservable)
        
        // Combine latest both so data will periodly get updated with socket callback and the very first snapshot REST API data.
        Observable.combineLatest(
            snapshotObservable,
            // Convenient unwrap socket data so we don't need to check nil manually
            socketRelay.unwrap()
        )
        // Simulate network delay when forceRefreshing
        .delay(.seconds(reloadReason == .initial ? 0 : 2), scheduler: ConcurrentMainScheduler.instance)
        .catch({ [weak self] error in
            self?.update(newState: .error(error))
            return Observable.empty()
        })
        .bind(onNext: { [weak self] snapshotData, socketData in
            guard let self = self else { return }
            // Forward snapshotData and socketData to Interactor for keeping local snapshot updated
            // https://github.com/binance/binance-spot-api-docs/blob/master/web-socket-streams.md#how-to-manage-a-local-order-book-correctly
            let snapshot = self.localOrderBook ?? snapshotData
            if let updatedLocalSnapshot = self.interactor.updateLocalSnapshot(snapshot, with: socketData) {
                // Calculate total bid/ask quantity in order to determine the depth level
                let totalBidQuantity = updatedLocalSnapshot.bids.reduce(0, { $0 + $1.quantity })
                let totalAskQuantity = updatedLocalSnapshot.asks.reduce(0, { $0 + $1.quantity })
                var accumulateTotalBid: Decimal = 0
                var accumulateTotalAsk: Decimal = 0
                let currencyPair = self.currencyPair
                self.orderBookCellViewModels = (0..<AppConfiguration.orderBookDefaultRowsCount).map { i in
                    let bidPriceLevel = updatedLocalSnapshot.bids[safe: i]
                    let askPriceLevel = updatedLocalSnapshot.asks[safe: i]
                    accumulateTotalBid += (bidPriceLevel?.quantity ?? 0)
                    accumulateTotalAsk += (askPriceLevel?.quantity ?? 0)
                    // Create cellViewModel with corresponding information
                    return OrderBookCellViewModel(
                        bidPriceLevel: bidPriceLevel,
                        askPriceLevel: askPriceLevel,
                        bidQuantityPercentage: !bidPriceLevel.isNil ? accumulateTotalBid / totalBidQuantity : 0,
                        askQuantityPercentage: !askPriceLevel.isNil ? accumulateTotalAsk / totalAskQuantity : 0,
                        currencyPair: currencyPair
                    )
                }
                // Update localOrderBook for next processing
                self.localOrderBook = updatedLocalSnapshot
            } else {
                // Unconsistent error detected after trying to update localSnapshot
                // We will force refreshing here
                self.loadData(reloadReason: .corruptedData)
            }
        })
        .disposed(by: disposedBag)
    }
    
    static func generatePlaceholderViewModels() -> [OrderBookCellViewModelProtocol] {
        return (0..<AppConfiguration.orderBookDefaultRowsCount).map { _ in PlacaholderOrderBookCellViewModel() }
    }
}

// MARK: - DataSource

extension OrderBookViewModel {
    var cellViewModelsDriver: Driver<[OrderBookCellViewModelProtocol]> {
        return cellViewModelsRelay.asDriver()
    }
}
