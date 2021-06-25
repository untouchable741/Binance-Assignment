//
//  FractionConfiguration.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 25/06/2021.
//

import Foundation

protocol FractionConfigurable {
    var quantityFraction: FractionConfiguration { get }
    var priceFraction: FractionConfiguration { get }
}

struct FractionConfiguration {
    let min: Int
    let max: Int
}
