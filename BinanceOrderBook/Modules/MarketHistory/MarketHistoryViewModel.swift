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
    
    var viewModelStateRelay = BehaviorRelay<RxViewModelState>(value: .initial)
    
    // Relays
    
    private var disposedBag = DisposeBag()
    private let snapshotRelay = BehaviorRelay<[AggregateTradeData]?>(value: nil)
    private let socketRelay = BehaviorRelay<AggregateTradeData?>(value: nil)
    private let cellViewModelsRelay = BehaviorRelay<[MarketHistoryCellViewModelProtocol]>(value: MarketHistoryViewModel.generatePlaceholderViewModels())
    
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
            cellViewModels = MarketHistoryViewModel.generatePlaceholderViewModels()
            // Disposed all previous disposables
            disposedBag = DisposeBag()
        }
        
        // Trigger update state
        update(newState: .loading("Loading market history data"))
        
        // Create observables to retrieve data
        let socketStreamObservable = interactor.subscribeStream(currencyPair: currencyPair)
        let snapshotObservable = interactor.getAggregateTradeData(currencyPair: currencyPair)
        
        // Firstly subscribe to socket stream and observe values
        socketStreamObservable
            .bind(to: socketRelay)
            .disposed(by: disposedBag)
        
        // Fetch aggregateTrade Snapshot from REST API
        snapshotObservable
            .asObservable()
            // AggregateTrade snapshot don't need to wait for socket connection open like DepthChart
            // So we don't need to take(until:) here, outdated data will be simply ignore in bind(onNext:)
            .bind(to: snapshotRelay)
            .disposed(by: disposedBag)
        
        // Combine latest both so data will periodly get updated with socket callback and the very first snapshot REST API data.
        Observable.combineLatest(
            // Take 1 because snapshot REST API is Single and should only fired once, subsequent fired should be ignores
            // Reversed here so all subsequent data after this fire will be in correct order
            snapshotRelay.unwrap().take(1).map { Array($0.reversed()) },
            // Convenient unwrap socket data so we don't need to check nil manually
            socketRelay.unwrap()
        )
        // Simulate network delay when forceRefreshing
        .delay(.seconds(isForcedRefresh ? 1 : 0), scheduler: ConcurrentMainScheduler.instance)
        .bind(onNext: { [weak self] snapshotData, socketData in
            guard let self = self else { return }
            var snapshot: [AggregateTradeData] = self.snapshotRelay.value ?? []
            if socketData.tradeTime.timeIntervalSince1970 > snapshot.first?.tradeTime.timeIntervalSince1970 ?? 0 {
                snapshot.insert(socketData, at: 0)
                snapshot.removeLast()
            }
            // Update snapshot relay with latest data for subsequent data processing
            self.snapshotRelay.accept(snapshot)
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
