//
//  SocketManager.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import Starscream
import Foundation
import RxSwift
import RxCocoa

typealias SocketDataResponse = (stream: String, data: Data)

final class SocketManager {
    static let shared = SocketManager()
    private var socket: WebSocket?
    private var connectionStatusRelay = BehaviorRelay<SocketConnectionStatus>(value: .initial)
    private var dataPublishSubject = PublishSubject<SocketDataResponse>()
    private var pendingRequest: [StreamRequest] = []
}

extension SocketManager: SocketDataProvider {
    
    var connectionStatusObservable: Observable<SocketConnectionStatus> {
        return connectionStatusRelay.asObservable()
    }
    
    func connectIfNeeded() {
        guard connectionStatusRelay.value != .connected else {
            return
        }
        var request = URLRequest(url: URL(string: "wss://stream.binance.com/stream")!)
        request.timeoutInterval = 60
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
        connectionStatusRelay.accept(.connecting)
    }
    
    func disconnect() {
        socket?.disconnect()
    }
    
    func subscribe<T: Decodable>(streamName streamNames: [String]) -> Observable<T> {
        let subscribeRequest = StreamRequest(
            id: Int(Date.timeIntervalBetween1970AndReferenceDate),
            method: .subscribe,
            params: streamNames
        )
        
        guard let subscribeRequestJSONString = subscribeRequest.jsonString else {
            return Observable.error(SocketError.invalidRequest)
        }
        
        if let socket = socket {
            socket.write(string: subscribeRequestJSONString)
        } else {
            // Socket not available, put message into stream and processs later
            pendingRequest.append(subscribeRequest)
            connectIfNeeded()
        }
        
        return dataPublishSubject
            .filter { streamNames.contains($0.stream) }
            .map { try JSONDecoder().decode(T.self, from: $0.data) }
    }
    
    func unsubscribe(streamName streamNames: [String]) throws {
        guard let socket = socket else {
            return
        }
        
        let unsubscribeRequest = StreamRequest(
            id: Int(Date.timeIntervalBetween1970AndReferenceDate),
            method: .unsubscribe,
            params: streamNames
        )
        
        guard let unsubscribeRequestJSONString = unsubscribeRequest.jsonString else {
            throw SocketError.invalidRequest
        }
        
        socket.write(string: unsubscribeRequestJSONString)
    }
    
    func send(request: StreamRequest) {
        guard let subscribeRequestJSONString = request.jsonString else {
            return
        }
        socket?.write(string: subscribeRequestJSONString)
    }
}

extension SocketManager: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
            case .connected(let headers):
                connectionStatusRelay.accept(.connected)
                pendingRequest.forEach(send)
                print("websocket is connected: \(headers)")
            case .disconnected(let reason, let code):
                connectionStatusRelay.accept(.disconnected)
                print("websocket is disconnected: \(reason) with code: \(code)")
            case .text(let string):
                let jsonResponse = string.jsonObject
                if let streamName = jsonResponse?["stream"] as? String,
                   let dataJsonResponse = jsonResponse?["data"],
                   let data = try? JSONSerialization.data(withJSONObject: dataJsonResponse) {
                    dataPublishSubject.onNext((streamName, data))
                }
            case .binary(_):
                break
            case .ping(_):
                break
            case .pong(_):
                break
            case .viabilityChanged(_):
                break
            case .reconnectSuggested(_):
                break
            case .cancelled:
                connectionStatusRelay.accept(.disconnected)
            case .error(let error):
                connectionStatusRelay.accept(.error(error?.localizedDescription))
            }
    }
}
