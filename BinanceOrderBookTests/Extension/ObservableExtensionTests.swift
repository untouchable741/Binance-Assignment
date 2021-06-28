//
//  ObservableExtensionTests.swift
//  BinanceOrderBookTests
//
//  Created by Vuong Huu Tai on 28/06/2021.
//

import XCTest
import RxCocoa
@testable import BinanceOrderBook

final class ObservableExtensionTests: XCTestCase {

    func testUnwrap_whenPublishNotNilValue() {
        // Given
        let expectation = expectation(description: #function)
        let sut = BehaviorRelay<Int?>(value: 9)
        
        // When
        let disposable = sut.asObservable()
            .unwrap()
            .bind { value in
                XCTAssertEqual(String(describing: type(of: value)), "Int")
                expectation.fulfill()
            }
        
        // Then
        waitForExpectations(timeout: 0.1) { _ in
            disposable.dispose()
        }
    }
    
    func testUnwrap_whenPublishNilValue() {
        // Given
        let expectation = expectation(description: #function)
        // Expected bind won't be called since unwrap is filtering out all nil value so we set expectation as inverted here
        expectation.isInverted = true
        let sut = BehaviorRelay<Int?>(value: nil)
        
        // When
        let disposable = sut.asObservable()
            .unwrap()
            .bind { value in
                expectation.fulfill()
            }
        
        // Then
        waitForExpectations(timeout: 0.1) { _ in
            disposable.dispose()
        }
    }
}
