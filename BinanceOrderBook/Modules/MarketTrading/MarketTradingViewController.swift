//
//  MarketTradingViewController.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import UIKit
import Tabman
import Pageboy

final class MarketTradingViewController: TabmanViewController {

    private var tabViewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViewControllers()
        setupTabAppearance()
    }
}

private extension MarketTradingViewController {
    func setupViewControllers() {
        let orderBookViewController: OrderBookViewController = UIStoryboard.makeViewController(for: .orderBook(currencyPair: .BTCUSDT))
        let marketHistoryViewController: MarketHistoryViewController = UIStoryboard.makeViewController(for: .marketHistory(currencyPair: .BTCUSDT))
        tabViewControllers = [
            orderBookViewController,
            marketHistoryViewController
        ].compactMap { $0 }
    }
    
    func setupTabAppearance() {
        let bar = TMBar.ButtonBar()
        self.dataSource = self
        bar.layout.transitionStyle = .snap
        bar.layout.alignment = .centerDistributed
        bar.layout.contentInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
        bar.buttons.customize { (button) in
            button.contentInset = .init(top: 0, left: 0, bottom: 10, right: 0)
            button.font = UIFont.boldSystemFont(ofSize: 14.0)
            button.tintColor = .lightGray
            button.selectedTintColor = UIColor.yellow
            button.backgroundColor = .black
        }
        bar.backgroundView.style = .clear
        bar.indicator.weight = .light
        bar.indicator.tintColor = UIColor.yellow
        addBar(bar, dataSource: self, at: .navigationItem(item: navigationItem))
    }
}

extension MarketTradingViewController: PageboyViewControllerDataSource, TMBarDataSource {

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return tabViewControllers.count
    }

    func viewController(
        for pageboyViewController: PageboyViewController,
        at index: PageboyViewController.PageIndex
    ) -> UIViewController? {
        return tabViewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }

    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        return TMBarItem(title: index == 0 ? "OrderBook" : "Market History")
    }
}

