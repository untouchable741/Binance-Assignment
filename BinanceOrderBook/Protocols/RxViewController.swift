//
//  RxViewController.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import Foundation
import RxSwift

protocol RxViewController where Self: UIViewController {
    var viewModelStateObservable: Observable<RxViewModelState> { get }
    func bindViewModelState() -> Disposable
    func onInitialize()
    func onFinishedLoadData()
    func onLoadingChanged(status: String?, isLoading: Bool)
    func onError(_ error: Error)
}

extension RxViewController {
    func onInitialize() { }
    func onFinishedLoadData() { }
    func onLoadingChanged(status: String?, isLoading: Bool) { }
    func onError(_ error: Error) { }
}

extension RxViewController {
    func bindViewModelState() -> Disposable {
        return viewModelStateObservable
            .bind { [weak self] state in
            if state != .loading(nil) {
                self?.onLoadingChanged(status: nil, isLoading: false)
            }
            switch state {
            case .initial:
                self?.onInitialize()
            case .loading(let status):
                self?.onLoadingChanged(status: status, isLoading: true)
            case .finishedLoadData:
                self?.onFinishedLoadData()
            case .error(let error):
                self?.onError(error)
            }
        }
    }
}


