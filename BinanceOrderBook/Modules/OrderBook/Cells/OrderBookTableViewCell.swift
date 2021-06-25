//
//  OrderBookTableViewCell.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 25/06/2021.
//

import UIKit

class OrderBookTableViewCell: UITableViewCell {

    @IBOutlet weak var bidQuantityLabel: UILabel!
    @IBOutlet weak var bidPriceLabel: UILabel!
    @IBOutlet weak var askQuantityLabel: UILabel!
    @IBOutlet weak var askPriceLabel: UILabel!
    @IBOutlet weak var bidQuantityBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var askQuantityBarWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(viewModel: OrderBookCellViewModel) {
        let cellContentViewWidth = contentView.bounds.width / 2
        bidQuantityLabel.text = viewModel.formattedBidQuantity
        bidPriceLabel.text = viewModel.formattedBidPrice
        askQuantityLabel.text = viewModel.formattedAskQuantity
        askPriceLabel.text = viewModel.formattedAskPrice
        bidQuantityBarWidthConstraint.constant  = CGFloat((viewModel.bidQuantityPercentage as NSDecimalNumber).floatValue) * cellContentViewWidth
        askQuantityBarWidthConstraint.constant  = CGFloat((viewModel.askQuantityPercentage as NSDecimalNumber).floatValue) * cellContentViewWidth
    }
}
