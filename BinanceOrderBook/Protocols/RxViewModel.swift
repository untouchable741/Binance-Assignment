//
//  RxViewModel.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 25/06/2021.
//

import Foundation
import RxSwift
import RxCocoa

enum RxViewModelState {
    case initial
    case loading(String)
    case loadedData
    case error(Error)
}

protocol RxViewModel {
    var viewModelStateObservable: Observable<RxViewModelState> { get }
}
