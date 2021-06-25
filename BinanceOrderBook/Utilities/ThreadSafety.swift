//
//  ThreadSafeWrapper.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 25/06/2021.
//

import Foundation

@propertyWrapper
class ThreadSafety<Value> {
    private let accessingQueue: DispatchQueue
    private var value: Value
    
    var wrappedValue: Value {
        get { accessingQueue.sync { value } }
        set { accessingQueue.async(flags: .barrier) { self.value = newValue } }
    }

    init(value: Value, queue: DispatchQueue? = nil) {
        self.value = value
        self.accessingQueue = queue ?? DispatchQueue(label: UUID().uuidString, attributes: .concurrent)
    }
}
