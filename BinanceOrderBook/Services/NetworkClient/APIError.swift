//
//  APIError.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import Foundation

enum APIError: Error {
    case invalidRequest
    case invalidResponse
    case conversionFailure
}
