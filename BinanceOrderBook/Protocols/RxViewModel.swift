//
//  RxViewModel.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 25/06/2021.
//

import Foundation
import RxSwift
import RxCocoa

/// We could have used
/// RxViewModelState<T> {
///     case loadedData(T)
/// }
///
/// protocol RxViewModel {
///     associatedType DataType
///     var viewModelStateObservable: Observable<RxViewModelState<DataType>> { get }
/// }
///
/// To make the RxViewModelState more flexible with data type that used inside each module
/// But that will have a drawback because where we define ViewModel that conform to this RxViewModel
/// We won't be able to define let viewModel: OrderBookViewModel<DepthResponse> <= swift does not support specify protocol associatedType on definition like this.
/// In that case we won't be able to use protocol but instead need to define a concrete ViewModel.
enum RxViewModelState: Equatable {
    case initial
    case loading(String?)
    case finishedLoadData
    case error(Error)
    
    static func == (lhs: RxViewModelState, rhs: RxViewModelState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial),
             (.finishedLoadData, .finishedLoadData),
             (.error, .error):
            return true
        case (.loading(let lhsStatus), .loading(let rhsStatus)):
            return lhsStatus == rhsStatus
        default:
            return false
        }
    }
}

protocol RxViewModel {
    var viewModelStateObservable: Observable<RxViewModelState> { get }
    var viewModelStateRelay: BehaviorRelay<RxViewModelState> { get }
    func update(newState: RxViewModelState)
}

extension RxViewModel {
    /// viewModelStateObservable should alway be observed on MainThread.
    var viewModelStateObservable: Observable<RxViewModelState> {
        return viewModelStateRelay
            .asObservable()
            .observe(on: MainScheduler.instance)
    }
    
    /// Convenient method to update state
    /// Override this method if we need to do additional steps before updating state (e.g: send analytics request before/after state changed)
    func update(newState: RxViewModelState) {
        viewModelStateRelay.accept(newState)
    }
}

