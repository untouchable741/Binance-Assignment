//
//  StatusView.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import UIKit

final class StatusView: UIView {

    enum State {
        case hidden
        case loading(String?)
        case error(String)
    }
    
    private var state: State = .hidden {
        didSet {
            DispatchQueue.main.async {
                self.updateUI(for: self.state)
            }
        }
    }
    
    func updateState(_ newState: State) {
        state = newState
    }
    
    private func updateUI(for state: State) {
        switch state {
        case .loading(let text):
            statusLabel.text = text ?? "Loading ..."
            activityIndicator.isHidden = false
            isHidden = false
        case .error(let errorDescription):
            statusLabel.text = errorDescription
            activityIndicator.isHidden = true
            isHidden = false
        default:
            isHidden = true
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
}
