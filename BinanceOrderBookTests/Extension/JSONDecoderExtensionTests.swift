//
//  JSONDecoderExtensionTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
@testable import BinanceOrderBook

final class JSONDecoderExtensionTests: XCTestCase {

    func testSharedDecoder() {
        // When
        let sut = JSONDecoder.shared
        
        // Then
        // JSONDecoder.DateDecodingStrategy' not conform to 'Equatable' and it has some custom enum so easiest way is to use switch - case and XCTFail(message:)
        switch sut.dateDecodingStrategy {
        case .millisecondsSince1970:
            break
        default:
            XCTFail("dateDecodingStrategy must be \(JSONDecoder.DateDecodingStrategy.millisecondsSince1970)")
        }
    }
}

