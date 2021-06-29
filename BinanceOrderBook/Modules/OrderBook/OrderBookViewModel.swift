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
    func forceRefreshSnapshotData()
    func loadData()
}

final class OrderBookViewModel: OrderBookViewModelProtocol {

    // Store properties
    private let currencyPair: CurrencyPair
    private let interactor: OrderBookInteractorProtocol
    private var waitingSnapshotUpdate: Bool = false
    @ThreadSafety(value: generatePlaceholderViewModels())
    private var orderBookCellViewModels: [OrderBookCellViewModelProtocol] {
        didSet {
            cellViewModelsRelay.accept(orderBookCellViewModels)
            update(newState: .finishedLoadData)
        }
    }
    private var localSnapshot: DepthChartResponseData?
    
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
    
    func loadData() {
        // Trigger loading state on UI
        update(newState: .loading("Loading OrderBook data ..."))
        
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
        .catch({ [weak self] error in
            self?.update(newState: .error(error))
            return Observable.empty()
        })
        // When there is corrupted data, skip combineLatest while waiting for snapshot to be updated.
        .skip(while: { [weak self] _ in self?.waitingSnapshotUpdate == true })
        .bind(onNext: { [weak self] snapshotData, socketData in
            guard let self = self else { return }
            // Forward snapshotData and socketData to Interactor for keeping local snapshot updated
            let snapshot = self.localSnapshot ?? snapshotData
            if let updatedLocalSnapshot = self.interactor.updateLocalSnapshot(snapshot, with: socketData) {
                self.handleUpdatedLocalSnapshot(updatedLocalSnapshot)
                // Update localOrderBook for next processing
                self.localSnapshot = updatedLocalSnapshot
            } else {
                // Unconsistent error detected after trying to update localSnapshot
                // Need to update the snapshot
                self.waitingSnapshotUpdate = true
                self.forceRefreshSnapshotData()
            }
        })
        .disposed(by: disposedBag)
    }
    
    func forceRefreshSnapshotData() {
        // If socket is not connecting, loadData again
        guard interactor.isSocketConnected else {
            return loadData()
        }
        
        // Otherwise, just need to refresh snapshot
        update(newState: .loading("Refreshing OrderBook data ..."))
        interactor
            .getDepthData(currencyPair: currencyPair)
            .subscribe(onSuccess: { [weak self] data in
                self?.localSnapshot = data
                self?.waitingSnapshotUpdate = false
            }, onFailure: { [weak self] error in
            self?.update(newState: .error(error))
        }).disposed(by: disposedBag)
    }
    
    func handleUpdatedLocalSnapshot(_ snapshot: DepthChartResponseData) {
        // Calculate total bid/ask quantity in order to determine the depth level
        let totalBidQuantity = snapshot.bids.reduce(0, { $0 + $1.quantity })
        let totalAskQuantity = snapshot.asks.reduce(0, { $0 + $1.quantity })
        var accumulateTotalBid: Decimal = 0
        var accumulateTotalAsk: Decimal = 0
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
