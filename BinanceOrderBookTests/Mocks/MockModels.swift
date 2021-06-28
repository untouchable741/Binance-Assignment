//
//  MockModels.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import Foundation
@testable import BinanceOrderBook

extension DepthChartResponseData {
    static func mock() -> Self {
        return DepthChartResponseData(
            lastUpdateId: 1111,
            bids: [
                PriceLevel(price: 1, quantity: 2)
            ],
            asks: [
                PriceLevel(price: 3, quantity: 4)
            ]
        )
    }
}

extension DepthChartSocketResponse {
    static func mock() -> Self {
        return DepthChartSocketResponse(
            eventType: "event_type",
            eventTime: Date(),
            symbol: .BTCUSDT,
            firstUpdateID: 1,
            finalUpdateID: 2,
            bids: [PriceLevel(price: 1, quantity: 2)],
            asks: [PriceLevel(price: 3, quantity: 4)]
        )
    }
}

extension AggregateTradeData {
    static func mock(
        tradeID: Int = 0,
        price: String = "",
        tradeTime: Date = Date()
    ) -> Self {
        return AggregateTradeData(
            eventType: "event_type",
            eventTime: Date(),
            symbol: .BTCUSDT,
            tradeID: tradeID,
            price: price,
            quantity: "2",
            firstTradeID: 2,
            lastTradeID: 3,
            tradeTime: tradeTime,
            isBuyer: true
        )
    }
}
