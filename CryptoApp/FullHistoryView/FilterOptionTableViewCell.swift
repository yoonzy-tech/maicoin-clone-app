//
//  FilterOptionTableViewCell.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/6.
//

import UIKit

class FilterOptionTableViewCell: UITableViewCell {

    @IBOutlet weak var coinIconImageView: UIImageView!
    
    @IBOutlet weak var coinCodeLabel: UILabel!
    
    func updateCell(coinName: String, selectedCoin: String) {
        tintColor = .darkGray
        accessoryType = coinName == selectedCoin ? .checkmark : .none
        
        if coinName == "所有幣種" {
            coinIconImageView.image = UIImage(named: "coin")
        } else {
            CoinbaseService.shared.getIconUrl(imageView: coinIconImageView,
                                              for: coinName, style: "black")
        }
        coinCodeLabel.text = coinName
    }
}
