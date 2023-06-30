//
//  ViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/28.
//

import UIKit
import MJRefresh

enum CurrencyName: String {
    case USD
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI Setup
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
        // Data Fetching
        requestAPIAgain()
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
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ProductsTableViewHeaderView")
                as? ProductsTableViewHeaderView
        else { fatalError("Unable to generate Table View Section Header") }
        
        switch section {
        case 0:
            return nil
        default:
            return headerView
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
            
            cell.accountTotalBalance = viewModel.accountTotalBalance.value
            
            return cell
        
        default:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProductListTableViewCell", for: indexPath) as? ProductListTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            
            let coinCode = viewModel.usdTradingPairs.value[indexPath.row].0
            cell.coinIconImageView.image = UIImage(named: coinCode)
            cell.coinNameLabel.text = coinCode
            cell.coinFullNameLabel.text = coinCodeToZHTWName[coinCode]
            let price = viewModel.fluctuateRateAvgPrice.value[indexPath.row].1
            cell.coinPriceLabel.text = price.formatMarketData()
            let rate = viewModel.fluctuateRateAvgPrice.value[indexPath.row].0
            cell.fluctRateLabel.text = "\(rate > 0 ? "+" : "")\(rate.formatMarketData())%"
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            
        case 1:
            performSegue(withIdentifier: "openCoinMarketChart", sender: nil)
        default:
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openCoinMarketChart" {
            let destinationVC = segue.destination as? CoinMarketChartViewController {
                
            }
        }
    }
}
