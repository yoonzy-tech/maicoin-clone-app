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
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBAction func confirmDetails(_ sender: Any) {
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
        
        if tabBarController?.selectedIndex == 1,
           navigationController?.viewControllers.contains(where: { $0 is OrderResultViewController }) == true {
            confirmButton.isHidden = true
        }
    }
    
    private func setupUI() {
        detailsView.layer.cornerRadius = 5
        sideTagButton.layer.cornerRadius = 5
        confirmButton.layer.cornerRadius = 5
        
        let phoneNumber = "(02)2722-1314"
        let emailAddress = "info@maicoin.com"
        let fullText = "訂單相關問題，請撥打客服專線\(phoneNumber)或來信至\(emailAddress)"
        let attributedString = NSMutableAttributedString(string: fullText)
        let phoneNumberRange = (fullText as NSString).range(of: phoneNumber)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: phoneNumberRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: phoneNumberRange)
        let emailRange = (fullText as NSString).range(of: emailAddress)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: emailRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: emailRange)
        infoLabel.attributedText = attributedString
    }
    
    func updateDetails(order: Order) {
        self.sideTagButton.setTitle(order.side == "buy" ? "BUY" : "SELL", for: .normal)
        self.sideTagButton.backgroundColor = UIColor(hexString: order.side == "buy" ? .green : .red)
        self.sizeLabel.text = order.size
        self.createdAtTimeLabel.text = order.createdAt.convertCoinbaseTimestamp()
        self.doneAtTimeLabel.text = order.doneAt?.convertCoinbaseTimestamp()
        
        let executedValue = order.executedValue.convertToDouble()
        let fees = order.fillFees.convertToDouble()
        let size = order.size.convertToDouble()
        let unitPrice = (executedValue - fees) / size
        self.priceLabel.text = "US$ " + unitPrice.formattedAccountingString(decimalPlaces: 2, accountFormat: true)
        self.fundsLabel.text = "US$ " + executedValue.formattedAccountingString(decimalPlaces: 8, accountFormat: true)
    }
}
