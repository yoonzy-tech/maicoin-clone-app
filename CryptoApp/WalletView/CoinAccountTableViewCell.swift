//
//  CoinAccountTableViewCell.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/6.
//

import UIKit
import Kingfisher

class CoinAccountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var currencyLabel: UILabel!
    
    @IBOutlet weak var accountBalanceLabel: UILabel!
    
    @IBOutlet weak var equivalentTWDLabel: UILabel!
    
    @IBOutlet weak var coinIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCell(data: Account) {
        currencyLabel.text = data.currency
        let accountBalance = data.balance.convertToDouble().formattedAccountingString(decimalPlaces: 8, accountFormat: true)
        accountBalanceLabel.text = accountBalance

        CoinbaseService.shared.getIconUrl(imageView: coinIconImageView, for: data.currency)
        
        let balance = data.balance.convertToDouble()
        let twdBalance = balance.convertToTWD()
        let formatted = twdBalance.formattedAccountingString(decimalPlaces: 2, accountFormat: true)
        equivalentTWDLabel.text = "NT$ \(formatted)"
    }
}
