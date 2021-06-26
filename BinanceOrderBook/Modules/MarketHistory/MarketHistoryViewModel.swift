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
    var numberOfOrders: Int { get }
    func model(at index: Int) -> MarketHistoryCellViewModelProtocol?
    func loadData()
}

final class MarketHistoryViewModel: MarketHistoryViewModelProtocol {
    private let currencyPair: CurrencyPair
    private let interactor: MarketHistoryInteractorProtocol
    @ThreadSafety(value: generatePlaceholderViewModels())
    private var cellViewModels: [MarketHistoryCellViewModelProtocol] {
        didSet {
            viewModelStateRelay.accept(.loadedData)
        }
    }
    
    var viewModelStateRelay = BehaviorRelay<RxViewModelState>(value: .initial)
    
    // Relays
    
    private let disposedBag = DisposeBag()
    private let snapshotRelay = BehaviorRelay<[AggregateTradeData]?>(value: nil)
    private let socketRelay = BehaviorRelay<AggregateTradeData?>(value: nil)
    
    init(
        currencyPair: CurrencyPair = .BTCUSDT,
        interactor: MarketHistoryInteractorProtocol = MarketHistoryInteractor()
    ) {
        self.currencyPair = currencyPair
        self.interactor = interactor
    }
    
    func loadData() {
        // Trigger update state
        update(newState: .loading("Loading data"))
        
        // Create observable to retrieve data
        let socketStreamObservable = interactor.subscribeStream(currencyPair: currencyPair)
        let snapshotObservable = interactor.getAggregateTradeData(currencyPair: currencyPair)
        
        // Firstly subscribe to socket stream
        socketStreamObservable
            .bind(to: socketRelay)
            .disposed(by: disposedBag)
        
        // Fetch aggregateTrade Snapshot
        snapshotObservable
            .asObservable()
            .bind(to: snapshotRelay)
            .disposed(by: disposedBag)
        
        // Combine latest both and ignore if either of them is nil
        // Ignore initial nil value of snapshot and take 1 to get only the first value from api callback
        // The subsequent value will be updated manually after each merge completed and should not trigger combine latest.
        Observable.combineLatest(
            snapshotRelay.compactMap { $0 }.take(1).map { Array($0.reversed()) },
            socketRelay.compactMap { $0 }
        )
        .bind(onNext: { [weak self] snapshotData, socketData in
            var snapshot: [AggregateTradeData] = self?.snapshotRelay.value ?? []
            if socketData.tradeTime.timeIntervalSince1970 > snapshot.first?.tradeTime.timeIntervalSince1970 ?? 0 {
                snapshot.insert(socketData, at: 0)
                snapshot.removeLast()
            }
            self?.snapshotRelay.accept(snapshot)
            self?.cellViewModels = snapshot
                .prefix(AppConfiguration.marketHistoryDefaultRowsCount)
                .map { model in
                MarketHistoryCellViewModel(
                    aggregateData: model,
                    currencyPair: .BTCUSDT
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
    var numberOfOrders: Int {
        return cellViewModels.count
    }
    
    func model(at index: Int) -> MarketHistoryCellViewModelProtocol? {
        return cellViewModels[index]
    }
}
