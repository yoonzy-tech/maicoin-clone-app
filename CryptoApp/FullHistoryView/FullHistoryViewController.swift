//
//  FullHistoryViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/6.
//

import UIKit
import MJRefresh
import JGProgressHUD

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getHistorty(coinName: filteredCoin)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        getHistorty(coinName: filteredCoin)
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
    
    func showServerErrorAlert() {
        let alert = UIAlertController(title: "500:內部伺服器錯誤",
                                      message: "系統無法取得資料，請稍候再試",
                                      preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "重新整理", style: .default) { [weak self] _ in
            self?.getHistorty(coinName: self?.filteredCoin ?? "")
        }
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    func getHistorty(coinName: String) {
        
        if coinName != "所有幣種" {
            if let coinHistories = CoinbaseService.shared.fetchProductOrdersNew(productID: "\(filteredCoin)-USD", limit: 100) {
                self.histories = coinHistories
            } else {
                print("Failed to get \(filteredCoin) to USD product order histories")
                // MARK: Handle Error, Recall API
                self.histories = []
                showServerErrorAlert()
            }
        } else {
            guard let coinHistories = CoinbaseService.shared.fetchProductOrdersNew(productID: "", limit: 100)  else {
                print("Failed to get \(filteredCoin) to USD product order histories")
                // MARK: Handle Error, Recall API
                showServerErrorAlert()
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
        tableView.mj_header = MJRefreshNormalHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshPage))
    }
    
    @objc func refreshPage() {
        getHistorty(coinName: filteredCoin)
        tableView.mj_header?.endRefreshing()
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
