//
//  FilterOptionViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/6.
//

import UIKit

class FilterOptionViewController: UIViewController {

    var accountsName: [String] = []
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func closeFilterOptions(_ sender: Any) {
        dismiss(animated: true)
    }
    
    weak var delegate: FilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "選擇幣種"
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAccounts()
    }

    func getAccounts() {
        guard let accounts: [Account] = CoinbaseService.shared.fetchAccountsNew() else {
            print("Failed to get accounts")
            return
        }
        accountsName = accounts.compactMap({ account in
            return account.currency
        })
    }
}

extension FilterOptionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        accountsName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FilterOptionTableViewCell", for: indexPath) as? FilterOptionTableViewCell
        else { fatalError("Unable to generate Table View Cell") }
        
        cell.updateCell(coinName: accountsName[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectCoin(coinName: accountsName[indexPath.row])
        dismiss(animated: true)
    }
}

protocol FilterDelegate: AnyObject {
    func didSelectCoin(coinName: String)
}
