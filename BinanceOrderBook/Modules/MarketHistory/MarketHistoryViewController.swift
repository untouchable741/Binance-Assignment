//
//  MarketHistoryViewController.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import UIKit
import RxSwift

class MarketHistoryViewController: UIViewController, StoryboardInstantiable {
    
    func configure(with currencyPair: CurrencyPair) {
        viewModel = MarketHistoryViewModel(currencyPair: currencyPair)
    }
    
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
    @IBOutlet weak var aggregateTableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: UIView!
    
    private var viewModel: MarketHistoryViewModelProtocol!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel
            .viewModelStateObservable
            .observe(on: MainScheduler.instance)
            .bind { [weak self] state in
            switch state {
            case .loadedData:
                UIView.animate(withDuration: 0.5) {
                    self?.loadingIndicatorView.isHidden = true
                }
                self?.aggregateTableView.reloadData()
            case .loading(_):
                UIView.animate(withDuration: 0.5) {
                    self?.loadingIndicatorView.isHidden = false
                }
            case .initial:
                self?.loadingIndicatorView.isHidden = true
            case .error(let error):
                break
            }
        }.disposed(by: disposeBag)
        
        viewModel.loadData()
    }
}

extension MarketHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfOrders
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarketHistoryTableViewCell", for: indexPath) as! MarketHistoryTableViewCell
        if let cellViewModel = viewModel.model(at: indexPath.row) {
            cell.configure(viewModel: cellViewModel)
        }
        return cell
    }
}
