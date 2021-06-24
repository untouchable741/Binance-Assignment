//
//  SocketConnectionProvider.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import Foundation
import RxSwift

enum SocketConnectionStatus {
    case initial
    case connecting
    case connected
    case disconnected
    case error(String?)
}

enum SocketError: Error {
    case invalidRequest
    case connectionFailure
}

protocol SocketDataProvider {
    // Observable to receive latest status of socket connection
    var connectionStatusObservable: Observable<SocketConnectionStatus> { get }
    
    // Public methods to handle connection
    func connect()
    func disconnect()
    
    // Public methods to handle subscribe and unsubscribe stream
    func subscribe<T: Decodable>(streamName streamNames: [String]) -> Observable<T>
    func unsubscribe(streamName: [String]) throws
}
