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

struct ProductPair {
    var coinCode: String
    var productPair: String
}

import UIKit
import Starscream

class BuySellViewController: UIViewController {
    
    var product: [String: String] = ["coinCode": "", "pair": ""]
    
    let websocket = WebsocketService.shared
    
    var actionType: ActionType = .buy
    
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
        websocket.subscribeProductID = productID
        websocket.connect()
        // Websocket completion to get ticker message
        websocket.completion = { [weak self] tickerMessage in
            let bid = tickerMessage.bestBid ?? ""
            let ask = tickerMessage.bestAsk ?? ""
            self?.realtimeRate = Double(self?.actionType == .buy ? bid : ask) ?? 0
            self?.updateUI()
        }
        getCurrencyAccount()
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
                let size = text.convertToDouble() ?? 0
                let price = size * rate
                bottomTextField.text = price.formattedAccountingString(decimalPlaces: 8,
                                                                       accountFormat: true)
            } else {
                let text = bottomTextField.text ?? "0"
                let price = text.convertToDouble() ?? 0
                let size = price / rate
                topTextField.text = size.formattedAccountingString(decimalPlaces: 8,
                                                                   accountFormat: true)
            }
        }
    }
}

// MARK: Text Field Delegate

extension BuySellViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let currentText = textField.text as NSString? else {
            return true
        }
        
        let newText = currentText.replacingCharacters(in: range, with: string)
        let number = Double(newText) ?? 0
        // Check if the new text exceeds the maximum limit
        if String(number).count > 12 {
            return false
        }
        
        // Check if the new text is empty
        if newText.isEmpty {
            textField.text = "0" // Assign "0" to the text field
            updateUI()
            return false // Prevent further editing
        }
        
        // Check if the first character is '0' and if the new text is not empty
        if newText.first == "0" && newText.count > 0 {
            // Find the index of the first non-zero character
            let nonZeroIndex = newText.firstIndex(where: { $0 != "0" }) ?? newText.endIndex
            // Remove the leading zero(s)
            textField.text = String(newText[nonZeroIndex...])
            updateUI()
             return false // Prevent further editing
        }
        
        if textField == topTextField,
           let text = topTextField.text,
           let enteredNumber = text.convertToDouble(),
           let balance = Double(currentBalance),
           enteredNumber > balance {
            return false
        }

        updateUI()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            textField.text = "0"
            updateUI()
        }
    }
}
