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

    private var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Order matters, viewControllers should be initialized before setting dataSource
        setupViewControllers()
        setupTab(theme: AppConstants.currentTheme)
        dataSource = self
    }
}

private extension MarketTradingViewController {
    func setupViewControllers() {
        let orderBookViewController: OrderBookViewController = UIStoryboard.makeViewController(for: .orderBook(currencyPair: .BTCUSDT))
        let marketHistoryViewController: MarketHistoryViewController = UIStoryboard.makeViewController(for: .marketHistory(currencyPair: .BTCUSDT))
        viewControllers = [
            orderBookViewController,
            marketHistoryViewController
        ].compactMap { $0 }
    }
    
    func setupTab(theme: AppThemeConfiguration) {
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .progressive
        bar.layout.alignment = .centerDistributed
        bar.layout.contentInset = .init(top: 0, left: 0, bottom: 10, right: 0)
        bar.buttons.customize {
            $0.contentInset = .zero
            $0.font = theme.tabBarFont
            $0.tintColor = theme.inactiveColor
            $0.selectedTintColor = theme.tintColor
            $0.backgroundColor = .black
        }
        bar.backgroundView.style = .clear
        bar.indicator.weight = .light
        bar.indicator.tintColor = theme.tintColor
        addBar(bar, dataSource: self, at: .navigationItem(item: navigationItem))
    }
}

extension MarketTradingViewController: PageboyViewControllerDataSource, TMBarDataSource {

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }

    func viewController(
        for pageboyViewController: PageboyViewController,
        at index: PageboyViewController.PageIndex
    ) -> UIViewController? {
        return viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }

    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        return TMBarItem(title: viewControllers[index].title ?? "")
    }
}

