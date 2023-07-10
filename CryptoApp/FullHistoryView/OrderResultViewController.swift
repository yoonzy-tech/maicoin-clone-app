//
//  OrderResultViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/4.
//

import UIKit

class OrderResultViewController: UIViewController {
    
    var orderDetails: Order?
    
    @IBOutlet weak var resultStatusLabel: UILabel!
    @IBOutlet weak var sideTagButton: UIButton!
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBOutlet weak var createdAtTimeLabel: UILabel!
    @IBOutlet weak var doneAtTimeLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var fundsLabel: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var detailsView: UIView!
    
    @IBAction func confirmDetails(_ sender: Any) {
        // Go to wallet page
        if let tabBarController = self.tabBarController {
            let desiredTabIndex = 1
            if desiredTabIndex < tabBarController.viewControllers?.count ?? 0 {
                tabBarController.selectedIndex = desiredTabIndex
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "訂單詳情"
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let orderDetails = orderDetails else { return }
        updateDetails(order: orderDetails)
        
        if tabBarController?.selectedIndex == 1 {
            confirmButton.isHidden = true
        }

    }
    
    private func setupUI() {
        detailsView.layer.cornerRadius = 5
        sideTagButton.layer.cornerRadius = 5
        confirmButton.layer.cornerRadius = 5
    }
    
    func updateDetails(order: Order) {
        // print("Side: \(order.side)")
        self.sideTagButton.setTitle(order.side == "buy" ? "BUY" : "SELL", for: .normal)
        self.sizeLabel.text = order.size
        self.createdAtTimeLabel.text = order.createdAt.convertCoinbaseTimestamp()
        self.doneAtTimeLabel.text = order.doneAt?.convertCoinbaseTimestamp()
        
        // unit price: Executed value - filled fee (response) / size
        let executedValue = order.executedValue.convertToDouble()
        let fees = order.fillFees.convertToDouble()
        let size = order.size.convertToDouble()
        let unitPrice = (executedValue - fees) / size
        self.priceLabel.text = "US$ " + unitPrice.formattedAccountingString(decimalPlaces: 2, accountFormat: true)

        // Red: Executed value
        self.fundsLabel.text = "US$ " + executedValue.formattedAccountingString(decimalPlaces: 8, accountFormat: true)
        
    }
}
