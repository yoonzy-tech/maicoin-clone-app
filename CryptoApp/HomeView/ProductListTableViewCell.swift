//
//  ProductListTableViewCell.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/28.
//

import UIKit

class ProductListTableViewCell: UITableViewCell {

    @IBOutlet weak var coinIconImageView: UIImageView!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinFullNameLabel: UILabel!
    @IBOutlet weak var coinPriceLabel: UILabel!
    @IBOutlet weak var fluctRateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
