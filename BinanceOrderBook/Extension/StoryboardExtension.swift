//
//  StoryboardExtension.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import Foundation
import UIKit

enum Scene {
    case orderBook(currencyPair: CurrencyPair)
    case marketHistory(currencyPair: CurrencyPair)
}

protocol StoryboardInstantiable {
    static var storyboardIdentifier: String { get }
    func configure(with currencyPair: CurrencyPair)
}

extension UIStoryboard {
    static let main = UIStoryboard(name: "Main", bundle: nil)
    static func makeViewController<T: UIViewController & StoryboardInstantiable>(for scene: Scene) -> T {
        guard let targetViewController = main.instantiateViewController(identifier: T.storyboardIdentifier) as? T else {
            fatalError("targetViewController must be \(type(of: T.self))")
        }
        switch scene {
        case .orderBook(let currencyPair),
             .marketHistory(let currencyPair):
            targetViewController.configure(with: currencyPair)
        }
        return targetViewController
    }
}
