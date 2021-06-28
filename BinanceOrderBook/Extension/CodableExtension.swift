//
//  CodableExtensions.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import Foundation

extension Encodable {
    var jsonString: String? {
        guard let data = data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    var data: Data? {
        return try? JSONEncoder().encode(self)
    }
}

