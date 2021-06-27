//
//  APIServices.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import Foundation
import RxSwift

protocol APIServices {
    func fetchDepthChartSnapshot(currencyPair: CurrencyPair, limit: Int) -> Single<DepthChartResponseData>
    func fetchAggregateTradeData(currencyPair: CurrencyPair, limit: Int) -> Single<[AggregateTradeData]>
}

final class APIClient: APIServices {
    private let sessionConfiguration: URLSessionConfiguration
    
    init(configuration: URLSessionConfiguration = .default) {
        self.sessionConfiguration = configuration
    }
    
    func fetchDepthChartSnapshot(currencyPair: CurrencyPair, limit: Int) -> Single<DepthChartResponseData> {
        guard let depthChartRequest = BinanceOrderBook.depthChart(symbol: currencyPair.rawValue, limit: limit).request else {
            return Single.error(APIError.invalidRequest)
        }
        return perform(request: depthChartRequest)
    }
    
    func fetchAggregateTradeData(currencyPair: CurrencyPair, limit: Int) -> Single<[AggregateTradeData]> {
        guard let aggregateTradeRequest = BinanceOrderBook.aggregateTradeData(symbol: currencyPair.rawValue, limit: limit).request else {
            return Single.error(APIError.invalidRequest)
        }
        return perform(request: aggregateTradeRequest)
    }
}

private extension APIClient {
    func perform<T: Codable>(request: URLRequest) -> Single<T> {
        let urlSession = URLSession.init(configuration: sessionConfiguration)
        return Single.create { single in
            let dataTask = urlSession.dataTask(with: request, completionHandler: { data, response, error in
                do {
                    if let error = error {
                        throw error
                    } else {
                        guard let data = data else {
                            throw APIError.invalidResponse
                        }
                        let decodedData = try JSONDecoder.shared.decode(T.self, from: data)
                        single(.success(decodedData))
                    }
                } catch (let finalError){
                    single(.failure(finalError))
                }
            })
            dataTask.resume()
            
            return Disposables.create {
                dataTask.cancel()
            }
        }
    }
}
