//
//  MarketHistoryTableViewCell.swift
//  BinanceOrderBook
//
//  Created by Vuong Huu Tai on 26/06/2021.
//

import UIKit

class MarketHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(
        viewModel: MarketHistoryCellViewModelProtocol,
        theme: AppThemeConfiguration = AppConstants.currentTheme
    ) {
        let isPlaceholder = (viewModel is PlacaholderMarketHistoryCellViewModel)
        timeLabel.text = viewModel.formattedTradeTime
        priceLabel.text = viewModel.formattedPrice
        quantityLabel.text = viewModel.formattedQuantity
        priceLabel.textColor = isPlaceholder ? theme.normalTextColor :
                            viewModel.isBuyer ? theme.bidTextColor : theme.askTextColor
    }
}

extension MarketHistoryTableViewCell: ReusableCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
