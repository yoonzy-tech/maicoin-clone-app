//
//  CoinMarketChartViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/30.
//

import UIKit
import Starscream

enum CBGranularity: Int {
    case hour = 3600
    case sixHours = 21600
    case twentyFourHours = 86400
}

class MarketChartViewController: UIViewController {

    var dayArr: [Double] = []
    
    var weekArr: [Double] = []
    
    var monthArr: [Double] = []
    
    var threeMonthArr: [Double] = []
    
    var yearArr: [Double] = []
    
    var allArr: [Double] = []
    
    let viewModel = MarketChartViewModel()
    
    // ("BTC", "BTC-USD") = (0: coinCode, 1: productID)
    var coinCodeProductID: (String, String) = ("", "")
    
    private var websocket = WebsocketService.shared
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    
    @IBAction func goBuyCoin(_ sender: Any) {
        performSegue(withIdentifier: "openBuySellPage", sender: sender)
    }
    
    @IBAction func goSellCoin(_ sender: Any) {
        performSegue(withIdentifier: "openBuySellPage", sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinders()
        callApis()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openBuySellPage",
           let button = sender as? UIButton,
           let destinationVC = segue.destination as? BuySellViewController {
            destinationVC.actionType = button.tag == 0 ? .buy : .sell
            destinationVC.title = button.tag == 0 ? "買入\(coinCodeProductID.0)" : "賣出\(coinCodeProductID.0)"
            // MARK: Pass Product Coin Code / Pair
            destinationVC.product = [
                "coinCode": coinCodeProductID.0,
                "pair": coinCodeProductID.1
            ]
        }
    }
    
    func callApis() {
        let productID = coinCodeProductID.1
        
        viewModel.getProductCandles(productID: productID, time: .day) { [weak self] candles in
            self?.dayArr = candles
        }
        
        viewModel.getProductCandles(productID: productID, time: .week) { [weak self] candles in
            self?.weekArr = candles
        }
        
        viewModel.getProductCandles(productID: productID, time: .month) { [weak self] candles in
            self?.monthArr = candles
        }
        
        viewModel.getProductCandles(productID: productID, time: .threeMonth) { [weak self] candles in
            self?.threeMonthArr = candles
        }
        viewModel.getYearCandles(productID: productID) { [weak self] candles in
            self?.yearArr = candles
        }
        viewModel.getAllCandles(productID: productID) { [weak self] candles in
            self?.allArr = candles
        }
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        websocket.subscribeProductID = coinCodeProductID.1
        websocket.connect()
        websocket.completion = { [weak self] tickerMessage in
            self?.updateRealtimeBuySell(bid: tickerMessage.bestBid, ask: tickerMessage.bestAsk)
        }
        viewModel.productID.value = coinCodeProductID.1
        viewModel.getProductOrderHistory()
    }
    
    func updateRealtimeBuySell(bid: String?, ask: String?) {
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ChartTableViewCell,
           let buyPrice = Double(ask ?? ""),
           let sellPrice = Double(bid ?? "") {
            cell.realtimeBuyPriceLabel.text = buyPrice.formatMarketDataString()
            cell.realtimeSellPriceLabel.text = sellPrice.formatMarketDataString()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        websocket.unsubscribe(productID: coinCodeProductID.1)
    }
    
    private func setupBinders() {
        viewModel.productID.bind { [weak self] _ in
            // self?.viewModel.getProductCandles()
            self?.viewModel.getProductOrderHistory()
        }
        
        viewModel.historyDataSource.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }
        }

        viewModel.candles.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        }
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.sectionHeaderTopPadding = 0
        tableView.register(UINib(nibName: "ChartTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "ChartTableViewCell")
        tableView.register(UINib(nibName: "HistoryTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "HistoryTableViewCell")
        tableView.register(UINib(nibName: "NoDataTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "NoDataTableViewCell")
        tableView.register(UINib(nibName: "HistoryHeaderView", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "HistoryHeaderView")
        buyButton.layer.cornerRadius = 5
        sellButton.layer.cornerRadius = 5
    }
}

// MARK: TableView Delegate

extension MarketChartViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return nil
        default:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HistoryHeaderView")
                    as? HistoryHeaderView
            else { fatalError("Unable to generate Table View Section Header") }
            headerView.navigationController = navigationController
            headerView.selectedCoin = coinCodeProductID.0
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.1
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            if let count = viewModel.historyDataSource.value?.count, count > 0 {
                return count
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChartTableViewCell", for: indexPath) as? ChartTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            
            cell.dayArray = dayArr
            cell.weekArray = weekArr
            cell.monthArray = monthArr
            cell.threeMonthArray = threeMonthArr
            cell.yearArray = yearArr
            cell.allArray = allArr
            cell.setChartView(dataArray: cell.dayArray)
            
            return cell
            
        default:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            
            if let data = viewModel.historyDataSource.value, data.count > 0 {
                cell.updateCell(data: data[indexPath.row], coinCode: coinCodeProductID.0)
            } else {
                // Now has no data
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell
                else { fatalError("Unable to generate Table View Cell") }
                return cell
            }
            
            return cell
        }
    }
}
