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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
