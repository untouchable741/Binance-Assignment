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
        
        // Firstly subscribe to socket stream and observe values
        let socketStreamObservable = interactor.subscribeStream(currencyPair: currencyPair)
        
        // Fetch aggregateTrade Snapshot from REST API
        // AggregateTrade snapshot don't need to wait for socket connection open like DepthChart
        // So we don't need to skip(until:) here, outdated data will be simply ignore in bind(onNext:)
        let snapshotObservable = interactor
            .getAggregateTradeData(currencyPair: currencyPair)
            .map { Array($0.reversed()) }
            .asObservable()
        
        Observable.combineLatest(
            snapshotObservable,
            socketStreamObservable
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
                if snapshot.count >= AppConfiguration.marketHistoryDefaultRowsCount {
                    snapshot.removeLast()
                }
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
