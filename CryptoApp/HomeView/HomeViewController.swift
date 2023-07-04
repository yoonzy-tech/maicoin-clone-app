//
//  ViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/28.
//

import UIKit
import MJRefresh
import Starscream

enum CurrencyName: String {
    case USD
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = HomeViewModel()
    
    var socket: WebSocket!
    
    var isConnected: Bool = false
    
    var passedCoinCode: String = ""
    
    var passedCoinName: String = ""
    
    var passCoinCodeProductID: (String, String) = ("", "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBinders()
        tableView.mj_header = MJRefreshNormalHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshPage))
    }
    
    @objc func refreshPage() {
        requestAPIAgain()
        tableView.mj_header?.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // Data Fetching
        requestAPIAgain()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func requestAPIAgain() {
        viewModel.getAccountsTotalBalance()
        viewModel.getUSDTradingPairs()
        viewModel.getUSDPairsProductFluctRateAvgPrice()
        viewModel.getCurrencyNames()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.sectionHeaderTopPadding = 0
        tableView.register(UINib(nibName: "BannerBalanceTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "BannerBalanceTableViewCell")
        tableView.register(UINib(nibName: "ProductListTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "ProductListTableViewCell")
        tableView.register(UINib(nibName: "ProductsTableViewHeaderView", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "ProductsTableViewHeaderView")
    }
    
    private func setupBinders() {
        viewModel.accountTotalBalance.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        }

        viewModel.usdTradingPairs.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }
        }
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Check if the scroll offset has reached the scroll edge threshold
        let scrollOffset = scrollView.contentOffset.y
        let scrollEdgeThreshold: CGFloat = 50 // Adjust this threshold value as per your requirement
        
        if scrollOffset >= scrollEdgeThreshold {
            // Set the title for the navigation bar when the scroll offset reaches the scroll edge threshold
            navigationItem.title = "市場"
            navigationController?.setNavigationBarHidden(false, animated: false)
        } else {
            // Remove the title otherwise
            navigationItem.title = nil
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
}

// MARK: TableView Delegate

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.1
        default:
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ProductsTableViewHeaderView")
                    as? ProductsTableViewHeaderView
            else { fatalError("Unable to generate Table View Section Header") }
            return headerView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1 // BannerBalanceCell
        default:
            return viewModel.usdTradingPairs.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "BannerBalanceTableViewCell", for: indexPath) as? BannerBalanceTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            
            cell.accountTotalBalance = viewModel.accountTotalBalance.value.convertToTWD().rounded()
            
            return cell
        
        default:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProductListTableViewCell", for: indexPath) as? ProductListTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            
            let coinCode = viewModel.usdTradingPairs.value[indexPath.row].0
            cell.coinCode = coinCode
            cell.price = viewModel.fluctuateRateAvgPrice.value[indexPath.row].1.convertToTWD().rounded()
            cell.rate = viewModel.fluctuateRateAvgPrice.value[indexPath.row].0
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            
        case 1:
            self.passedCoinCode = viewModel.usdTradingPairs.value[indexPath.row].0
            self.passedCoinName = coinCodeToZHTWName[self.passedCoinCode] ?? self.passedCoinCode
            self.passCoinCodeProductID = viewModel.usdTradingPairs.value[indexPath.row]
            performSegue(withIdentifier: "openCoinMarketChart", sender: nil)
        default:
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openCoinMarketChart",
            let destinationVC = segue.destination as? MarketChartViewController {
            destinationVC.title = "\(self.passedCoinName) (\(self.passedCoinCode))"
            print("PassCoinCodeProductID: \(passCoinCodeProductID)")
            destinationVC.coinCodeProductID = passCoinCodeProductID
        }
    }
}
