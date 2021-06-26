//
//  DateTimeFormatter.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import Foundation

// MARK: - OrderBookDateFormatter

protocol OrderBookDateFormatter {
    func timeString(from date: Date) -> String?
}

extension DateFormatter: OrderBookDateFormatter {
    func timeString(from date: Date) -> String? {
        dateFormat = "HH:mm:ss"
        return string(from: date)
    }
}

extension DateFormatter {
    static let sharedDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }()
}
