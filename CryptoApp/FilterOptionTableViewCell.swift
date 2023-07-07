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
    
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkImageView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkImageView.isHidden = selected ? false : true
    }
    
    func updateCell(coinName: String) {
        CoinbaseService.shared.getIconUrl(imageView: coinIconImageView,
                                          for: coinName, style: "black")
        coinCodeLabel.text = coinName
    }
}
