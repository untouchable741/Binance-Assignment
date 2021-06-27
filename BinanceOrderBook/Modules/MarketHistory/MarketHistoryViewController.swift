//
//  MarketHistoryViewController.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import UIKit
import RxSwift

class MarketHistoryViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var aggregateTradeTableView: UITableView!
    @IBOutlet var statusView: StatusView?
    
    private var viewModel: MarketHistoryViewModelProtocol!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelState()
            .disposed(by: disposeBag)
        setupUI()
        bindData()
        viewModel.loadData(isForcedRefresh: false)
    }
    
    func bindData() {
        viewModel.cellViewModelsDriver
            .drive(aggregateTradeTableView.rx.items) { tableView, index, cellViewModel in
                let marketHistoryCell: MarketHistoryTableViewCell = tableView.dequeReusableCell(indexPath: IndexPath(row: index, section: 0))
                marketHistoryCell.configure(viewModel: cellViewModel)
                return marketHistoryCell
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Private

extension MarketHistoryViewController {
    func setupUI() {
        setupPullToRefresh()
        setupTableView()
    }
    
    func setupTableView() {
        aggregateTradeTableView.tableFooterView = UIView(frame: .zero)
    }
    
    func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshHandler(sender:)), for: .valueChanged)
        aggregateTradeTableView.refreshControl = refreshControl
    }
    
    @objc func refreshHandler(sender: UIRefreshControl) {
        viewModel.loadData(isForcedRefresh: true)
        sender.endRefreshing()
    }
}

// MARK: - StoryboardInstantiable conformance

extension MarketHistoryViewController: StoryboardInstantiable {
    
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
    
    func configure(with currencyPair: CurrencyPair) {
        // Set titlte so it will be shown on the MarketTrading tab
        title = "Order Book"
        viewModel = MarketHistoryViewModel(currencyPair: currencyPair)
    }
}

// MARK: - RxViewController conformance

extension MarketHistoryViewController: RxViewController {
    var viewModelStateObservable: Observable<RxViewModelState> {
        return viewModel.viewModelStateObservable
    }

    func onFinishedLoadData() {
        // Do additional things after data is loaded
        // We don't need to reload tableView here because we're all have cellViewModelsDriver
    }
    
    func onLoadingChanged(status: String?, isLoading: Bool) {
        UIView.animate(withDuration: 0.5) {
            if isLoading {
                self.statusView?.updateState(.loading(status))
            } else {
                self.statusView?.updateState(.hidden)
            }
        }
    }
    
    func onError(_ error: Error) {
        UIView.animate(withDuration: 0.5) {
            self.statusView?.updateState(.error(error.localizedDescription))
        }
    }
}
