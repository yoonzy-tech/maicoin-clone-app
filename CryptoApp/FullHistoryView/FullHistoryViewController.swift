//
//  FullHistoryViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/6.
//

import UIKit

class FullHistoryViewController: UIViewController {
    
    var histories: [Order] = []
    
    var filteredCoin: String = "所有幣種" {
        didSet {
            getHistorty(coinName: filteredCoin)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var filterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "資產紀錄"
        setupTableView()
        filterButton.setTitle(filteredCoin, for: .normal)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getHistorty(coinName: filteredCoin)
    }
    
    @IBAction func openFilterSheet(_ sender: Any) {
        if let filterOptionVC = storyboard?
            .instantiateViewController(withIdentifier: "FilterOptionViewController") as? FilterOptionViewController,
           let sheetPresentationController = filterOptionVC.sheetPresentationController {
            filterOptionVC.delegate = self
            filterOptionVC.selectedCoin = filteredCoin
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.prefersGrabberVisible = true
            present(filterOptionVC, animated: true, completion: nil)
        }
    }
    
    func getHistorty(coinName: String) {
        // get the first 100 transactions in the past 6 months
        if coinName != "所有幣種" {
            if let coinHistories = CoinbaseService.shared.fetchProductOrdersNew(productID: "\(filteredCoin)-USD", limit: 100) {
                print("Failed to get \(filteredCoin) to USD product order histories")
                self.histories = coinHistories
            } else {
                self.histories = []
            }
        } else {
            guard let coinHistories = CoinbaseService.shared.fetchProductOrdersNew(productID: "", limit: 100)  else {
                print("Failed to get \(filteredCoin) to USD product order histories")
                return
            }
            self.histories = coinHistories
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "HistoryTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "HistoryTableViewCell")
        tableView.register(UINib(nibName: "NoDataTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "NoDataTableViewCell")
    }
}

// MARK: - Table View Delegate

extension FullHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count > 0 ? histories.count : 1

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if histories.count > 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            
            let productID = histories[indexPath.row].productId
            let coinCode = productID.replacingOccurrences(of: "-USD", with: "")
            cell.updateCell(data: histories[indexPath.row], coinCode: coinCode)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let orderResultVC = storyboard?
         .instantiateViewController(withIdentifier: "OrderResultViewController")
                 as? OrderResultViewController else { return }
        
        let order = histories[indexPath.row]
        // print("Order: \(order)")
        orderResultVC.orderDetails = order
        navigationController?.pushViewController(orderResultVC, animated: true)
    }
}

extension FullHistoryViewController: FilterDelegate {
    func didSelectCoin(coinName: String) {
        self.filteredCoin = coinName
        filterButton.setTitle(filteredCoin, for: .normal)
        tableView.reloadData()
    }
}
