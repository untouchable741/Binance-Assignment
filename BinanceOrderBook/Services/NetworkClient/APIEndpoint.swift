//
//  APIEndpoint.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

protocol BinanceAPIEndpoint {
    var method: HTTPMethod { get }
    var baseUrlString: String { get }
    var apiPath: String { get }
    var headers: [String: String] { get }
    var queryParameters: [String : String] { get }
    var body: [String: String]? { get }
    var request: URLRequest? { get }
}

enum BinanceOrderBook {
    case depthChart(symbol: String, limit: Int)
    case aggregateTradeData(symbol: String, limit: Int)
}

extension BinanceOrderBook: BinanceAPIEndpoint {
    
    var method: HTTPMethod {
        return .GET
    }
    
    var baseUrlString: String {
        return AppConfiguration.baseUrlString
    }
    
    var apiPath: String {
        switch self {
        case .depthChart:
            return "/depth"
        case .aggregateTradeData:
            return "/aggTrades"
        }
    }
    
    var headers: [String : String] {
        return [:]
    }
    
    var body: [String : String]? {
        return nil
    }

    
    var queryParameters: [String : String] {
        switch self {
        case .depthChart(let symbol, let limit),
             .aggregateTradeData(let symbol,let limit):
            return [
                "symbol": symbol,
                "limit": String(limit)
            ]
        }
    }
    
    var request: URLRequest? {
        // Build URL from baseUrlString and apiPath
        var urlComponent = URLComponents(string: baseUrlString)
        urlComponent?.path.append(contentsOf: apiPath)
        
        // Handle query items
        urlComponent?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        // Make sure url is created properly
        guard let url = urlComponent?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        
        // Assign HTTPMethod
        request.httpMethod = method.rawValue
        
        // Handle headers
        headers.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        // HTTP Body
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        }
        
        return request
    }
}
