//
//  BuySellViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/4.
//

enum ActionType {
    case buy
    case sell
}

import UIKit

class BuySellViewController: UIViewController {

    var actionType: ActionType = .buy
    
    var enableTopTextField: Bool = false
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var topCurrencyButton: UIButton!
    @IBOutlet weak var bottomCurrencyButton: UIButton!
    
    @IBOutlet weak var converterView: UIView!
    @IBOutlet weak var spendGainLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var sendDealButton: UIButton!
    
    @IBAction func switchEditableField(_ sender: Any) {
        enableTopTextField = !enableTopTextField
        topTextField.isEnabled = enableTopTextField ? true : false
        bottomTextField.isEnabled = enableTopTextField ? false : true
        topTextField.textColor = enableTopTextField ? UIColor.darkGray : UIColor.lightGray
        bottomTextField.textColor = enableTopTextField ? UIColor.lightGray : UIColor.darkGray
        typeLabel.textColor = enableTopTextField ? UIColor.darkGray : UIColor.lightGray
        spendGainLabel.textColor = enableTopTextField ? UIColor.lightGray : UIColor.darkGray
    }
    
    @IBAction func sendDeal(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        topTextField.borderStyle = .none
        bottomTextField.borderStyle = .none
        typeLabel.text = actionType == .buy ? "買入" : "賣出"
        typeLabel.textColor = UIColor.lightGray
        topTextField.textColor = UIColor.lightGray
        spendGainLabel.text = actionType == .buy ? "花費" : "獲得"
        sendDealButton.setTitle(actionType == .buy ? "買入" : "賣出", for: .normal)
        sendDealButton.layer.cornerRadius = 5
        converterView.layer.cornerRadius = 5
        noteLabel.text = actionType == .buy ? "5 USDT ≤ 單筆購買額度 ≤ 60,000 USDT" :
        "可用餘額：0.05326852 BTC\n0.0002 BTC ≤ 單筆出售額度 ≤ 2 BTC"
        topTextField.isEnabled = false
        // Navigation Close Button
        navigationItem.backBarButtonItem = nil
        let closeButton = UIBarButtonItem(image: UIImage(named: "close"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(closeVC))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    @objc func closeVC() {
        navigationController?.popViewController(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openOrderResult",
        let destinationVC = segue.destination as? OrderResultViewController {
            destinationVC.title = "訂單詳請"
        }
    }
}
