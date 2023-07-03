//
//  HistoryTableViewCell.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/1.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusColorView: UIView!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var dealPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        statusColorView.layer.cornerRadius = statusColorView.frame.width / 2
        typeButton.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateCell(data: Order, coinCode: String) {
        self.volumeLabel.text = data.size
        let price = Double(data.price) ?? 0
        self.dealPriceLabel.text = "US$ \(price.rounded().formatMarketDataString())"
        self.timeLabel.text = data.doneAt.convertCoinbaseTimestamp()
        self.descriptionLabel.text = (data.side == "buy" ? "購入" : "售出") + " \(coinCode)"
        self.statusLabel.text = statusTWZH[data.status]
        self.typeButton.setTitle(data.side == "buy" ? "Buy" : "Sell", for: .normal)
    }
}

let statusTWZH = [
    "open": "開啟",
    "pending": "待處理",
    "rejected": "已拒絕",
    "done": "完成",
    "active": "進行中",
    "received": "已收到",
    "all": "全部"
]
