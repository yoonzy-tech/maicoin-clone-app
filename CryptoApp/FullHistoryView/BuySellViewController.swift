//
//  BuySellViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/4.
//

enum ActionType: String {
    case buy
    case sell
}

struct ProductPair {
    var coinCode: String
    var productPair: String
}

protocol OrderDelegate: AnyObject {
    func didSendOrder(orderID: String)
}

import UIKit
import Starscream

class BuySellViewController: UIViewController {
    
    var productPack: ProductPack = ProductPack()
    
    var product: [String: String] = ["coinCode": "", "pair": ""]
    
    let websocket = WebsocketService.shared
    
    var actionType: ActionType = .buy
    
    var orderID: String = ""
    
    var orderDetails: Order?
    
    var enableTopTextField: Bool = false {
        didSet {
            topTextField.isEnabled = enableTopTextField ? true : false
            bottomTextField.isEnabled = enableTopTextField ? false : true
            topTextField.textColor = enableTopTextField ? UIColor.darkGray : UIColor.lightGray
            bottomTextField.textColor = enableTopTextField ? UIColor.lightGray : UIColor.darkGray
            typeLabel.textColor = enableTopTextField ? UIColor.darkGray : UIColor.lightGray
            spendGainLabel.textColor = enableTopTextField ? UIColor.lightGray : UIColor.darkGray
        }
    }
    
    var realtimeRate: Double = 0 {
        didSet {
            updateUI()
        }
    }
    
    var ticker: TickerMessage?
    
    var currentBalance: String = ""
    
    var useMaxBalance: Bool = false
    
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var topCurrencyButton: UIButton!
    @IBOutlet weak var bottomCurrencyButton: UIButton!
    
    @IBOutlet weak var converterView: UIView!
    @IBOutlet weak var spendGainLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var maxButton: UIButton!
    @IBOutlet weak var sendDealButton: UIButton!
    
    @IBAction func switchEditableField(_ sender: Any) {
        enableTopTextField = !enableTopTextField
    }
    
    @IBAction func useMaxBalance(_ sender: Any) {
        useMaxBalance = true
        let maxBalance = Double(currentBalance) ?? 0
        topTextField.text = maxBalance.formattedAccountingString(decimalPlaces: 8, accountFormat: true)
        enableTopTextField = true
        let price = (Double(currentBalance) ?? 0) * realtimeRate
        let formattedPrice = price.formattedAccountingString(decimalPlaces: 8, accountFormat: true)
        bottomTextField.text = formattedPrice
    }
    
    @IBAction func sendDeal(_ sender: Any) {
        let size = topTextField.text ?? ""
        let productID = product["pair"] ?? ""
        
        // Check if has sufficient balance
        if size.convertToDouble() > currentBalance.convertToDouble() {
            // ProgressHUD.show("餘額不足\n請輸入有效餘額", icon: .exclamation)
            return
        }
        
        // Double confirm if wanna sell all the coins
        if size.convertToDouble() == currentBalance.convertToDouble() {
            let coinCode = product["coinCode"] ?? ""
            let alert = UIAlertController(title: "想全數售出此貨幣嗎?",
                                          message: "此操作將出售您帳戶中的所有\(coinCode)\n確定要繼續嗎？",
                                          preferredStyle: .alert)
            // MARK: 🚨 For development purpose, do nothing in cofirmation !!!
            let cancelAction = UIAlertAction(title: "取消", style: .default) { _ in return }
            let confirmAction = UIAlertAction(title: "確認", style: .destructive) { _ in return }
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
            
        } else {
            guard let orderID = CoinbaseService.shared.createOrders(
                size: size,
                side: actionType.rawValue,
                productId: productID) else {
                print("Unable to get the posted order id")
                return
            }
            self.orderID = orderID
            print("✅ I got the order ID: \(orderID)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.orderDetails = CoinbaseService.shared.fetchCompletedOrderNew(orderID: orderID)
                self.performSegue(withIdentifier: "openOrderResult", sender: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Dismiss Keyboard Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let productID = product["pair"] ?? ""
        websocket.subscribeProductId = productID
        websocket.connect()
        websocket.completion = { [weak self] tickerMessage in
            let bid = tickerMessage.bestBid ?? ""
            let ask = tickerMessage.bestAsk ?? ""
            self?.realtimeRate = Double(self?.actionType == .buy ? bid : ask) ?? 0
            self?.updateUI()
        }
        getCurrencyAccount()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let productID = product["pair"] ?? ""
        websocket.unsubscribe(productId: productID)
    }
    
    private func getCurrencyAccount() {
        let coinCode = product["coinCode"] ?? ""
        let accounts = CoinbaseService.shared.fetchAccountsNew()
        let currentAccount = accounts?.filter { $0.currency == coinCode }
        currentBalance = currentAccount?.first?.balance ?? "0"
        let balance = Double(currentBalance) ?? 0
        let formattedBalance = balance.formattedAccountingString(decimalPlaces: 8, accountFormat: true)
        noteLabel.text = actionType == .buy ? "" :
        "可用餘額：\(formattedBalance) \(coinCode)"
    }
    
    private func setupUI() {
        let coinCode = product["coinCode"] ?? ""
        topCurrencyButton.setTitle(coinCode, for: .normal)
        topCurrencyButton.setImage(UIImage(named: coinCode), for: .normal)
        topTextField.borderStyle = .none
        bottomTextField.borderStyle = .none
        typeLabel.text = actionType == .buy ? "買入" : "賣出"
        typeLabel.textColor = UIColor.lightGray
        topTextField.textColor = UIColor.lightGray
        spendGainLabel.text = actionType == .buy ? "花費" : "獲得"
        sendDealButton.setTitle(actionType == .buy ? "買入" : "賣出", for: .normal)
        sendDealButton.layer.cornerRadius = 5
        converterView.layer.cornerRadius = 5
        maxButton.isHidden = actionType == .buy ? true : false
        
        topTextField.isEnabled = false
        topTextField.delegate = self
        bottomTextField.delegate = self
        bottomTextField.becomeFirstResponder()
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
            destinationVC.orderDetails = orderDetails
        }
    }
}

// MARK: Update UI Functions

extension BuySellViewController {
    private func updateUI() {
        // Update UI
        if let coinCode = product["coinCode"] {
            let rate = realtimeRate.roundedDouble(toDecimalPlaces: 3)
            let formattedRate = rate.formattedAccountingString(decimalPlaces: 3, accountFormat: true)
            let labelText = "1 \(coinCode) = \(formattedRate) USD"
            let attributedString = NSMutableAttributedString(string: labelText)
            // Define the range of text that should be bold
            let boldRange = (labelText as NSString).range(of: "\(formattedRate)")
            // Apply the bold attribute to the specified range
            let boldFont = UIFont.boldSystemFont(ofSize: 22) // Set the desired bold font
            attributedString.addAttribute(.font, value: boldFont, range: boldRange)
            // Update Text Change Rate Label
            self.exchangeRateLabel.attributedText = attributedString
            
            if topTextField.isEditing {
                let text = topTextField.text ?? "0"
                let size = text.convertToDouble()
                let price = size * rate
                bottomTextField.text = price.formattedAccountingString(decimalPlaces: 8,
                                                    accountFormat: true)
            } else {
                let text = bottomTextField.text ?? "0"
                let price = text.convertToDouble()
                let size = price / rate
                topTextField.text = size.formattedAccountingString(decimalPlaces: 8,
                                                                   accountFormat: true)
            }
        }
    }
}

// MARK: Text Field Delegate

extension BuySellViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateUI()
        // if top text field text is larger than the balance (show HUD)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let currentText = textField.text as NSString? else {
            return true
        }
        
        let newText = currentText.replacingCharacters(in: range, with: string)
        print("New Text: \(newText)")

        if newText.isEmpty {
            textField.text = "0"
            updateUI()
            return false
        }
        
        if newText.first == "0" && newText.count > 0 {
            let nonZeroIndex = newText.firstIndex(where: { $0 != "0" }) ?? newText.endIndex
            textField.text = String(newText[nonZeroIndex...])
            updateUI()
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            textField.text = "0"
            updateUI()
        }
    }
}
