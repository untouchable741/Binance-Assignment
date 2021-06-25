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
    
    func bid(at index: Int) -> PriceLevel?
    func ask(at index: Int) -> PriceLevel?
    func loadData()
}

final class OrderBookViewModel: OrderBookViewModelProtocol {
    
    // Store properties
    
    private let currencyPair: CurrencyPair
    private let interactor: OrderBookInteractorProtocol
    @ThreadSafety private var orderBookData: DepthChartResponseData? {
        didSet {
            viewModelStateRelay.accept(.loadedData)
        }
    }
    
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
                self?.orderBookData = mergedLocalOrderBook
            }
        })
        .disposed(by: disposedBag)
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
        return orderBookData?.bids.count ?? 0
    }
    
    func bid(at index: Int) -> PriceLevel? {
        return orderBookData?.bids[index]
    }
    
    func ask(at index: Int) -> PriceLevel? {
        return orderBookData?.asks[index]
    }
}
