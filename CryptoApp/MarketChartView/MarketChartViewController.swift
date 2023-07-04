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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinders()
        callApis()
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
        websocket.connect()
        websocket.socket.delegate = self
        viewModel.getProductOrderHistory()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WebsocketService.shared.unsubscribe(productID: coinCodeProductID.1)
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

// MARK: Websocket Delegate

extension MarketChartViewController: WebSocketDelegate {
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            // subscribe to channel
            WebsocketService.shared.subscribe(productID: coinCodeProductID.1)
            print("websocket is connected: \(headers)")
            
        case .disconnected(let reason, let code):
            print("WebSocket is disconnected: \(reason) with code: \(code)")
            
        case .text(let string):
            // print("Received text: \(string)")
            do {
                let jsonData = string.data(using: .utf8)!
                let tickerData = try JSONDecoder().decode(TickerMessage.self, from: jsonData)
               
//                 print("Type: \(tickerData.type)")
//                 print("Sequence: \(tickerData.sequence)")
//                 print("Product ID: \(tickerData.productId)")
//                 print("Price: \(tickerData.price)")
                
                let indexPath = IndexPath(row: 0, section: 0)
                if let cell = tableView.cellForRow(at: indexPath) as? ChartTableViewCell,
                   let buyPrice = Double(tickerData.bestAsk ?? ""),
                   let sellPrice = Double(tickerData.bestBid ?? "") {
                    cell.realtimeBuyPriceLabel.text = buyPrice.formatMarketDataString()
                    cell.realtimeSellPriceLabel.text = sellPrice.formatMarketDataString()
                }
                
            } catch {
                print("Error decoding JSON: \(error)")
            }
        case .binary:
            break
        case .ping:
            break
        case .pong:
            break
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            break
        case .error(let error):
            print(error?.localizedDescription ?? "Websocket encountered an error")
        }
    }
}
