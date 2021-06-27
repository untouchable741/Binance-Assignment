//
//  OrderBookViewController.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import UIKit
import RxSwift
import RxCocoa

final class OrderBookViewController: UIViewController {
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var orderTableView: UITableView!
    @IBOutlet var statusView: StatusView?
    
    var viewModel: OrderBookViewModelProtocol!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelState()
            .disposed(by: disposeBag)
        setupUI()
        bindData()
        viewModel.loadData(isForcedRefresh: false)
    }
}

// MARK: - Private

extension OrderBookViewController {
    func setupUI() {
        setupPullToRefresh()
        setupTableView()
    }
    
    func setupTableView() {
        orderTableView.tableFooterView = UIView(frame: .zero)
    }
    
    func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppConstants.currentTheme.tintColor
        refreshControl.addTarget(self, action: #selector(refreshHandler(sender:)), for: .valueChanged)
        orderTableView.refreshControl = refreshControl
    }
    
    @objc func refreshHandler(sender: UIRefreshControl) {
        viewModel.loadData(isForcedRefresh: true)
        sender.endRefreshing()
    }
    
    func bindData() {
        viewModel.cellViewModelsDriver
            .drive(orderTableView.rx.items) { tableView, index, orderBookCellViewModel in
                let orderBookTableViewCell: OrderBookTableViewCell = tableView.dequeReusableCell(indexPath: IndexPath(row: index, section: 0))
                orderBookTableViewCell.configure(viewModel: orderBookCellViewModel)
                return orderBookTableViewCell
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - StoryboardInstantiable conformance

extension OrderBookViewController: StoryboardInstantiable {
    
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
    
    func configure(with currencyPair: CurrencyPair) {
        // Set titlte so it will be shown on the MarketTrading tab
        title = "Order Book (\(currencyPair.rawValue))"
        viewModel = OrderBookViewModel(currencyPair: currencyPair)
    }
}

// MARK: - RxViewController conformance

extension OrderBookViewController: RxViewController {
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
