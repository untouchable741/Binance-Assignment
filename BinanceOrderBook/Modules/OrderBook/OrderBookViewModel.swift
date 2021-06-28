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
            try? interactor.unsubscribeStream(currencyPair: currencyPair)
        case .forcedRefresh:
            try? interactor.unsubscribeStream(currencyPair: currencyPair)
            orderBookCellViewModels = Self.generatePlaceholderViewModels()
        case .initial:
            break
        }
    }
    
    func loadData(isForcedRefresh: Bool) {
        loadData(reloadReason: isForcedRefresh ? .forcedRefresh : .initial)
    }
    
    func loadData(reloadReason: ReloadReason) {
        // Set internal state for reload purpose
        prepareState(for: reloadReason)
        
        // Trigger loading state on UI
        update(newState: .loading(reloadReason.status))
        
        // https://github.com/binance/binance-spot-api-docs/blob/master/web-socket-streams.md#how-to-manage-a-local-order-book-correctly
        // According to documentation about how to manage local orderBook
        // Socket data should be open first but it data will be skipped until receiving first snapshot from API
        let snapshotObservable = interactor
            .getDepthData(currencyPair: currencyPair)
            .asObservable()
        
        let socketObservable = interactor
            .subscribeStream(currencyPair: currencyPair)
            .skip(until: snapshotObservable)
        
        // Combine latest both of them so everytime new socket data came, we will receive (previousSnapshot, latestSocketData)
        // Then use latestSocketData to update previousSnapshot to create updated snapshot Data.
        Observable.combineLatest(
            snapshotObservable,
            socketObservable
        )
        .delay(.seconds(reloadReason == .initial ? 0 : 2), scheduler: ConcurrentMainScheduler.instance)
        .catch({ [weak self] error in
            self?.update(newState: .error(error))
            return Observable.empty()
        })
        .bind(onNext: { [weak self] snapshotData, socketData in
            guard let self = self else { return }
            // Forward snapshotData and socketData to Interactor for keeping local snapshot updated
            let snapshot = self.localOrderBook ?? snapshotData
            if let updatedLocalSnapshot = self.interactor.updateLocalSnapshot(snapshot, with: socketData) {
                self.handleUpdatedLocalSnapshot(updatedLocalSnapshot)
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
    
    func handleUpdatedLocalSnapshot(_ snapshot: DepthChartResponseData) {
        // Calculate total bid/ask quantity in order to determine the depth level
        let totalBidQuantity = snapshot.bids.reduce(0, { $0 + $1.quantity })
        let totalAskQuantity = snapshot.asks.reduce(0, { $0 + $1.quantity })
        var accumulateTotalBid: Decimal = 0
        var accumulateTotalAsk: Decimal = 0
        let currencyPair = currencyPair
        self.orderBookCellViewModels = (0..<AppConfiguration.orderBookDefaultRowsCount).map { i in
            let bidPriceLevel = snapshot.bids[safe: i]
            let askPriceLevel = snapshot.asks[safe: i]
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
    }
    
    // In order to be reused inside @ThreadSafety propertyWrapper we need to make it static func
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
