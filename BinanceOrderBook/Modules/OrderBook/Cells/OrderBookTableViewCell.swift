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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(
        currencyPair: CurrencyPair,
        bid: PriceLevel,
        ask: PriceLevel,
        formatter: OrderBookNumberFormatter = NumberFormatter.sharedNumberFormatter
    ) {
        bidQuantityLabel.text = formatter.quantityString(from: NSDecimalNumber(string: bid.quantity), of: currencyPair)
        bidPriceLabel.text = formatter.priceString(from: NSDecimalNumber(string: bid.price), of: currencyPair)
        askQuantityLabel.text = formatter.quantityString(from: NSDecimalNumber(string: ask.quantity), of: currencyPair)
        askPriceLabel.text = formatter.priceString(from: NSDecimalNumber(string: ask.price), of: currencyPair)
    }

}
