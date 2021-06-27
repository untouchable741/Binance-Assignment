//
//  ArrayExtension.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 27/06/2021.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
