//
//  UITableViewExtension.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 27/06/2021.
//

import Foundation
import UIKit

extension UITableView {
    func dequeReusableCell<T: ReusableCell>(indexPath: IndexPath) -> T {
        guard let targetTableViewCell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("dequeued cell must be \(type(of: T.self))")
        }
        return targetTableViewCell
    }
}
