//
//  OrderBookViewModel.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import Foundation
import RxSwift
import RxCocoa

protocol OrderBookViewModelProtocol {
    var ordersObservable: Observable<DepthChartResponseData?> { get }

    func loadData()
}

final class OrderBookViewModel {
    
    private let interactor: OrderBookInteractorProtocol
    private var depthChartDataRelay = BehaviorRelay<DepthChartResponseData?>(value: nil)
    private let disposedBag = DisposeBag()
    
    private let snapshotRelay = BehaviorRelay<DepthChartResponseData?>(value: nil)
    private let socketRelay = BehaviorRelay<DepthChartSocketResponse?>(value: nil)
    private let orderBookRelay = BehaviorRelay<DepthChartResponseData?>(value: nil)
    
    init(interactor: OrderBookInteractorProtocol) {
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
            let mergedLocalOrderBook = self?.interactor.merge(snapshot: snapshotData, socketData: socketData)
            self?.orderBookRelay.accept(mergedLocalOrderBook)
        })
        .disposed(by: disposedBag)
    }
}

extension OrderBookViewModel: OrderBookViewModelProtocol {
    var ordersObservable: Observable<DepthChartResponseData?> {
        return orderBookRelay.asObservable()
    }
}
