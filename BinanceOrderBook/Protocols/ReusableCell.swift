//
//  ReusableCell.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 27/06/2021.
//

import Foundation

protocol ReusableCell {
    static var reuseIdentifier: String { get }
}
