//
//  MockSocketProvider.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import Foundation
import RxSwift
@testable import BinanceOrderBook

final class MockSocketProvider: SocketDataProvider {
    var stubIsSocketConnected: Bool = false
    var isSocketConnected: Bool {
        return stubIsSocketConnected
    }
    
    var stubConnectionStatusObservable: Observable<SocketConnectionStatus>!
    var connectionStatusObservable: Observable<SocketConnectionStatus> {
        return stubConnectionStatusObservable
    }
    
    private(set) var connectionIfNeededCalledCount: Int = 0
    func connectIfNeeded() {
        connectionIfNeededCalledCount += 1
    }
    
    private(set) var disconnectCalledCount: Int = 0
    func disconnect() {
        disconnectCalledCount += 1
    }
    
    private(set) var subscribeCalledCount: Int = 0
    private(set) var subscribeStreamNames: [String]?
    var stubSubscribeResponse: Decodable!
    func subscribe<T>(streamNames: [String]) -> Observable<T> where T : Decodable {
        subscribeCalledCount += 1
        subscribeStreamNames = streamNames
        return Observable.just(stubSubscribeResponse as! T)
    }
    
    private(set) var unsubscribeCalledCount: Int = 0
    private(set) var unsubscribeStreamNames: [String]?
    func unsubscribe(streamNames: [String]) throws {
        unsubscribeCalledCount += 1
        unsubscribeStreamNames = streamNames
    }
}
