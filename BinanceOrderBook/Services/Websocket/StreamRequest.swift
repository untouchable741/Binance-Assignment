//
//  StreamRequest.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import Foundation

enum StreamRequestMethod: String, Codable {
    case subscribe = "SUBSCRIBE"
    case unsubscribe = "UNSUBSCRIBE"
}

struct StreamRequest: Codable {
    let id: Int
    let method: StreamRequestMethod
    let params: [String]
}
