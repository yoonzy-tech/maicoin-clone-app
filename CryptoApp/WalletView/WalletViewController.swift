//
//  WalletViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/6.
//

import UIKit
import MJRefresh

class WalletViewController: UIViewController {
    
    var hideBalance: Bool = false
    
    var twdAccountBalance: Double = 0
    
    var accounts: [Account] = [] {
        didSet {
            
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hideBalanceButton: UIButton!
    @IBOutlet weak var totalBalance: UILabel!
    
    @IBAction func hideBalance(_ sender: Any) {
        hideBalance = !hideBalance
        hideBalanceButton.setImage(hideBalance ? UIImage(named: "eye-close") : UIImage(named: "eye-open"), for: .normal)
        let formattedBalance = twdAccountBalance.formattedAccountingString(decimalPlaces: 0, accountFormat: true)
        totalBalance.text = "NT$ \(hideBalance ? "******" : "\(formattedBalance)")"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "錢包"
        setupTableView()
        tableView.mj_header = MJRefreshNormalHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshPage))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAccounts()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.sectionHeaderTopPadding = 0
        tableView.register(UINib(nibName: "CoinAccountTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "CoinAccountTableViewCell")
    }
    
    @objc func refreshPage() {
        getAccounts()
        tableView.mj_header?.endRefreshing()
    }
    
    private func getAccounts() {
        guard let accounts = CoinbaseService.shared.fetchAccountsNew() else {
            print("No accounts data")
            return
        }
        
        self.accounts = accounts.sorted(by: { $0.currency < $1.currency })
        
        twdAccountBalance = accounts.reduce(0) { partialResult, account in
            if let rate = CoinbaseService.shared.getExchangeRate(from: account.currency) {
                let currencyBalance = account.balance.convertToDouble()
                return partialResult + (currencyBalance * rate)
            } else {
                print("Failed to get exchange for \(account.currency) to TWD")
                return partialResult
            }
        }

        let remainTwdBalance = twdAccountBalance.formattedAccountingString(decimalPlaces: 0, accountFormat: true)
        self.totalBalance.text = "NTS \(remainTwdBalance)"
    }
}

extension WalletViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CoinAccountTableViewCell", for: indexPath) as? CoinAccountTableViewCell
        else { fatalError("Unable to generate Table View Cell") }
        
        cell.updateCell(data: accounts[indexPath.row])
        
        return cell
    }
}
