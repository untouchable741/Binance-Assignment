//
//  MarketHistoryViewModel.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import Foundation
import RxSwift
import RxCocoa

protocol MarketHistoryViewModelProtocol: RxViewModel {
    // Binding
    var cellViewModelsDriver: Driver<[MarketHistoryCellViewModelProtocol]> { get }
    
    // Public method
    func loadData(isForcedRefresh: Bool)
}

final class MarketHistoryViewModel: MarketHistoryViewModelProtocol {
    private let currencyPair: CurrencyPair
    private let interactor: MarketHistoryInteractorProtocol
    @ThreadSafety(value: generatePlaceholderViewModels())
    private var cellViewModels: [MarketHistoryCellViewModelProtocol] {
        didSet {
            cellViewModelsRelay.accept(cellViewModels)
            viewModelStateRelay.accept(.finishedLoadData)
        }
    }
    private var localTradeData: [AggregateTradeData]?
    
    var viewModelStateRelay = BehaviorRelay<RxViewModelState>(value: .initial)
    
    // Relays
    
    private var disposedBag = DisposeBag()
    private let socketRelay = BehaviorRelay<AggregateTradeData?>(value: nil)
    private let cellViewModelsRelay = BehaviorRelay<[MarketHistoryCellViewModelProtocol]>(value: generatePlaceholderViewModels())
    
    deinit {
        try? interactor.unsubscribeStream(currencyPair: currencyPair)
    }
    
    init(
        currencyPair: CurrencyPair = .BTCUSDT,
        interactor: MarketHistoryInteractorProtocol = MarketHistoryInteractor()
    ) {
        self.currencyPair = currencyPair
        self.interactor = interactor
    }
    
    func loadData(isForcedRefresh: Bool) {
        // Clear old data if this is forcedRefresh
        if isForcedRefresh {
            cellViewModels = Self.generatePlaceholderViewModels()
            // Disposed all previous disposables
        }
        
        // Trigger update state
        update(newState: .loading("Loading market history data"))
        
        // Create observables to retrieve data
        let socketStreamObservable = interactor.subscribeStream(currencyPair: currencyPair)

        // Firstly subscribe to socket stream and observe values
        socketStreamObservable
            .bind(to: socketRelay)
            .disposed(by: disposedBag)
        
        // Fetch aggregateTrade Snapshot from REST API
        // AggregateTrade snapshot don't need to wait for socket connection open like DepthChart
        // So we don't need to take(until:) here, outdated data will be simply ignore in bind(onNext:)
        let snapshotObservable = interactor
            .getAggregateTradeData(currencyPair: currencyPair)
            .map { Array($0.reversed()) }
            .asObservable()
        
        // Combine latest both so data will periodly get updated with socket callback and the very first snapshot REST API data.
        Observable.combineLatest(
            snapshotObservable,
            // Convenient unwrap socket data so we don't need to check nil manually
            socketRelay.unwrap()
        )
        // Simulate network delay when forceRefreshing
        .delay(.seconds(isForcedRefresh ? 1 : 0), scheduler: ConcurrentMainScheduler.instance)
        .catch({ [weak self] error in
            self?.update(newState: .error(error))
            return Observable.empty()
        })
        .bind(onNext: { [weak self] snapshotData, socketData in
            guard let self = self else { return }
            var snapshot: [AggregateTradeData] = self.localTradeData ?? snapshotData
            if socketData.tradeTime.timeIntervalSince1970 > snapshot.first?.tradeTime.timeIntervalSince1970 ?? 0 {
                snapshot.insert(socketData, at: 0)
                snapshot.removeLast()
            }
            
            // Update snapshot relay with latest data for subsequent data processing
            self.localTradeData = snapshot
            
            // Generate cellViewModels on updated snapshot
            let currencyPair = self.currencyPair
            self.cellViewModels = snapshot
                .prefix(AppConfiguration.marketHistoryDefaultRowsCount)
                .map { model in
                MarketHistoryCellViewModel(
                    aggregateData: model,
                    currencyPair: currencyPair
                )
            }
        })
        .disposed(by: disposedBag)
    }
    
    static func generatePlaceholderViewModels() -> [MarketHistoryCellViewModelProtocol] {
        return (0..<AppConfiguration.orderBookDefaultRowsCount).map { i in
            return PlacaholderMarketHistoryCellViewModel()
        }
    }
}

// MARK: - DataSource

extension MarketHistoryViewModel {
    var cellViewModelsDriver: Driver<[MarketHistoryCellViewModelProtocol]> {
        return cellViewModelsRelay.asDriver()
    }
}
