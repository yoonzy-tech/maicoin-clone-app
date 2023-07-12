//
//  ViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/28.
//

import UIKit
import MJRefresh
import Starscream

class HomeViewController: UIViewController {
    
    let viewModel = HomeViewModel()
    
    var passProductPack: ProductPack = ProductPack()
    
    @IBOutlet weak var tableView: UITableView!
    
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
        requestAPIAgain()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func requestAPIAgain() {
        viewModel.prepareHomepageData()
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

        viewModel.usdProductPacks.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }
        }
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        let scrollEdgeThreshold: CGFloat = 50
        
        if scrollOffset >= scrollEdgeThreshold {
            navigationItem.title = "市場"
            navigationController?.setNavigationBarHidden(false, animated: false)
        } else {
            navigationItem.title = nil
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
}

// MARK: - TableView Delegate

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
        
        case 0: // BannerBalanceCell
            return 1
        
        default: // ProductListCell
            return viewModel.usdProductPacks.value.count
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
            
            cell.coinCode = viewModel.usdProductPacks.value[indexPath.row].baseCurrency
            cell.price = viewModel.usdProductPacks.value[indexPath.row].averagePrice
            cell.rate = viewModel.usdProductPacks.value[indexPath.row].fluctuateRate
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            
        case 1:
            self.passProductPack = viewModel.usdProductPacks.value[indexPath.row]
            performSegue(withIdentifier: "openCoinMarketChart", sender: nil)
        
        default:
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openCoinMarketChart",
            let destinationVC = segue.destination as? MarketChartViewController {
            let coinNameInTW = coinCodeToZHTWName[passProductPack.baseCurrency] ?? ""
            destinationVC.title = "\(coinNameInTW) (\(passProductPack.baseCurrency))"
            destinationVC.viewModel.productPack.value = passProductPack
        }
    }
}
