//
//  StubLoader.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import Foundation

final class StubLoader: NSObject {
    static func load(fileName: String) -> Data {
        let bundle = Bundle(for: StubLoader.classForCoder())

        // Ask Bundle for URL of Stub
        let url = bundle.url(forResource: fileName, withExtension: "json")
        
        // Use URL to Create Data Object
        return try! Data(contentsOf: url!)
    }
}
