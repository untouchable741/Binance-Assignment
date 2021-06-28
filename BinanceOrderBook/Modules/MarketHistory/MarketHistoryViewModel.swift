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
    func forceRefreshSnapshotData()
    func loadData()
}

final class MarketHistoryViewModel: MarketHistoryViewModelProtocol {
    private let currencyPair: CurrencyPair
    private let interactor: MarketHistoryInteractorProtocol
    private var waitingSnapshotUpdate: Bool = false
    @ThreadSafety(value: generatePlaceholderViewModels())
    private var cellViewModels: [MarketHistoryCellViewModelProtocol] {
        didSet {
            cellViewModelsRelay.accept(cellViewModels)
            update(newState: .finishedLoadData)
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
    
    func loadData() {
        // Trigger update state
        update(newState: .loading("Loading MarketHistory data..."))
        
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
        .catch({ [weak self] error in
            self?.update(newState: .error(error))
            return Observable.empty()
        })
        .skip(while: { [weak self] _ in self?.waitingSnapshotUpdate == true })
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
    
    func forceRefreshSnapshotData() {
        // If socket is not connecting, loadData again
        guard interactor.isSocketConnected else {
            return loadData()
        }
        
        // Otherwise, just need to refresh snapshot
        cellViewModels = Self.generatePlaceholderViewModels()
        update(newState: .loading("Refreshing MarketHistory data..."))
        interactor
            .getAggregateTradeData(currencyPair: currencyPair)
            .map { Array($0.reversed()) }
            .subscribe(onSuccess: { [weak self] data in
                self?.localTradeData = data
                self?.waitingSnapshotUpdate = false
            }, onFailure: { [weak self] error in
            self?.update(newState: .error(error))
        }).disposed(by: disposedBag)
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
