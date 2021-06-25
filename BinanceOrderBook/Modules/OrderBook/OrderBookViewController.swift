//
//  OrderBookViewController.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 24/06/2021.
//

import UIKit
import RxSwift

class OrderBookViewController: UIViewController {
    @IBOutlet weak var orderTableView: UITableView!
    let viewModel: OrderBookViewModelProtocol = OrderBookViewModel(interactor: OrderBookInteractor())
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        
        orderTableView.tableFooterView = UIView(frame: .zero)
    }
    
    func bindViewModel() {
        viewModel
            .viewModelStateObservable
            .observe(on: MainScheduler.instance)
            .bind { [weak self] state in
            switch state {
            case .loadedData:
                self?.orderTableView.reloadData()
            default:
                break
            }
        }.disposed(by: disposeBag)
        
        viewModel.loadData()
    }
}

extension OrderBookViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfOrders
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderBookTableViewCell", for: indexPath) as! OrderBookTableViewCell
        if let cellViewModel = viewModel.cellViewModel(at: indexPath.row) {
            cell.configure(viewModel: cellViewModel)
        }
        return cell
    }
}
