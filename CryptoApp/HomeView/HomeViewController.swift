//
//  ViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/28.
//

import UIKit

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Data Fetching
        viewModel.getUSDProductList()
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
            // self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
        
        viewModel.USDProductList.bind { [weak self] _ in
            // self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
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
            return viewModel.USDProductList.value.count
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
            
            
            
            return cell
        }
    }
}
