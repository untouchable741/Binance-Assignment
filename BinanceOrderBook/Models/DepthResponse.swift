//
//  DepthResponse.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

struct DepthChartResponseData: Codable {
    let lastUpdateId: Int
    let bids: [PriceLevel]
    let asks: [PriceLevel]
}
