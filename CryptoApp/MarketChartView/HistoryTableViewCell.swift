//
//  HistoryTableViewCell.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/1.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    let statusTWZH = [
        "open": "開啟",
        "pending": "待處理",
        "rejected": "已拒絕",
        "done": "完成",
        "active": "進行中",
        "received": "已收到",
        "all": "全部"
    ]

    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusColorView: UIView!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var dealPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusColorView.layer.cornerRadius = statusColorView.frame.width / 2
        typeButton.layer.cornerRadius = 5
    }
    
    func updateCell(data: Order, coinCode: String) {
        self.volumeLabel.text = data.size
        let price = data.executedValue.convertToDouble()
        let priceString = price.formattedAccountingString(decimalPlaces: 2, accountFormat: true)
        self.dealPriceLabel.text = "US$ \(priceString)"
        let timestamp = data.doneAt ?? ""
        self.timeLabel.text = timestamp.convertCoinbaseTimestamp()
        self.descriptionLabel.text = (data.side == "buy" ? "購入" : "售出") + " \(coinCode)"
        self.statusLabel.text = statusTWZH[data.status]
        self.typeButton.setTitle(data.side == "buy" ? "BUY" : "SELL", for: .normal)
        self.typeButton.backgroundColor = UIColor(hexString: data.side == "buy" ? .green : .red)
    }
}
