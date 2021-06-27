//
//  RxObservablExtension.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 27/06/2021.
//

import Foundation
import RxSwift

extension ObservableType {
    public func unwrap<Result>() -> Observable<Result> where Element == Result? {
        return self.compactMap { $0 }
    }
}
