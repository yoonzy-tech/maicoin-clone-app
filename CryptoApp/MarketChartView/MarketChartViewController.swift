//
//  CoinMarketChartViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/30.
//

import UIKit
import Starscream
import JGProgressHUD

class MarketChartViewController: UIViewController {
    
    var newDayArr: [Candle] = []
    var newWeekArr: [Candle] = []
    var newMonthArr: [Candle] = []
    var newThreeMonthArr: [Candle] = []
    var newYearArr: [Candle] = []
    var newAllArr: [Candle] = []
    
    let viewModel = MarketChartViewModel()
    
    private var websocket = WebsocketService.shared
    
    let hud = JGProgressHUD()
    
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
        buyButton.layer.cornerRadius = 5
        sellButton.layer.cornerRadius = 5
        setupTableView()
        callApis()
        //        setupBinders()
    }
    
    func showServerErrorHUD(text: String) {
        let alert = UIAlertController(title: "伺服器錯誤",
                                      message: "暫時無法取得\(text)數據，請稍候再試",
                                      preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "重新整理", style: .default) { [weak self] _ in
            self?.callApis()
        }
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    func callApis() {
        hud.textLabel.text = "資料加載中"
        hud.show(in: self.view)
        let group = DispatchGroup()
        var countGroup = 0
        
        DispatchQueue.global().async {
            if self.newDayArr.isEmpty {
                group.enter()
                countGroup += 1
                print(countGroup)
                self.viewModel.getTimeCandles(time: .day) { [weak self] extractedCandles in
                    self?.newDayArr = extractedCandles
                    countGroup -= 1
                    print(countGroup)
                    group.leave()
                } errorHandle: { [weak self] error in
                    countGroup -= 1
                    print(countGroup)
                    group.leave()
                    print("Show Error HUD for 1 Day Candles: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.showServerErrorHUD(text: "當日")
                    }
                }
            }
            
            if self.newWeekArr.isEmpty {
                group.enter()
                countGroup += 1
                print(countGroup)
                self.viewModel.getTimeCandles(time: .week) { [weak self] extractedCandles in
                    self?.newWeekArr = extractedCandles
                    countGroup -= 1
                    print(countGroup)
                    group.leave()
                } errorHandle: { [weak self] error in
                    countGroup -= 1
                    print(countGroup)
                    group.leave()
                    print("Show Error HUD for 1 Week Candles: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.showServerErrorHUD(text: "當周")
                    }
                }
            }
            
            if self.newMonthArr.isEmpty {
                group.enter()
                countGroup += 1
                print(countGroup)
                self.viewModel.getTimeCandles(time: .month) { [weak self] extractedCandles in
                    self?.newMonthArr = extractedCandles
                    countGroup -= 1
                    print(countGroup)
                    group.leave()
                } errorHandle: { [weak self] error in
                    countGroup -= 1
                    print(countGroup)
                    group.leave()
                    print("Show Error HUD for 1 Month Candles: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.showServerErrorHUD(text: "當月")
                    }
                }
            }
            
            if self.newThreeMonthArr.isEmpty {
                group.enter()
                countGroup += 1
                print(countGroup)
                self.viewModel.getTimeCandles(time: .threeMonth) { [weak self] extractedCandles in
                    self?.newThreeMonthArr = extractedCandles
                    countGroup -= 1
                    print(countGroup)
                    group.leave()
                } errorHandle: { [weak self] error in
                    countGroup -= 1
                    print(countGroup)
                    group.leave()
                    print("Show Error HUD for 3 Months Candles: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.showServerErrorHUD(text: "前三月")
                    }
                }
            }
            
            if self.newYearArr.isEmpty {
//                group.enter()
                countGroup += 1
                print(countGroup)
                self.viewModel.getYearCandles(group: group) { [weak self] extractedCandles in
                    self?.newYearArr = extractedCandles
                    print("----- Year out ----")
                    countGroup -= 1
                    print(countGroup)
//                    group.leave()
                } errorHandle: { [weak self] error in
                    print("----- Year out ----")
                    countGroup -= 1
                    print(countGroup)
//                    group.leave()
                    print("Show Error HUD for Year Candles: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.showServerErrorHUD(text: "當年")
                    }
                }
            }
            
            let concurrentQueue = DispatchQueue(label: "com.example.concurrentQueue", attributes: .concurrent)
            
            if self.newAllArr.isEmpty {
                
                self.viewModel.getAllCandles { [weak self] extractedCandles in
                    self?.newAllArr = extractedCandles
                    
                } errorHandle: { [weak self] error in
                    
                    print("Show Error HUD for All Candles: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.showServerErrorHUD(text: "所有歷史")
                    }
                }
                
            }
            
            group.notify(queue: .main) {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    // Loading HUD Dismiss
                    self.hud.dismiss()
                }
            }
        }
        
        viewModel.getProductOrderHistoryNEW {
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }
            
        } errorHandle: { [weak self] error in
            print("Show Error HUD: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self?.showServerErrorHUD(text: "歷史訂單")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        websocket.subscribeProductId = viewModel.productPack.value.productId
        websocket.connect()
        websocket.completion = { [weak self] tickerMessage in
            self?.updateRealtimeBuySell(bid: tickerMessage.bestBid, ask: tickerMessage.bestAsk)
        }
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
        let productId = viewModel.productPack.value.productId
        websocket.unsubscribe(productId: productId)
    }
    
    private func setupBinders() {
        viewModel.candles.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        }
        viewModel.historyDataSource.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }
        }
    }
    
    private func setupTableView() {
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
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openBuySellPage",
           let button = sender as? UIButton,
           let destinationVC = segue.destination as? BuySellViewController {
            destinationVC.actionType = button.tag == 0 ? .buy : .sell
            
            let baseCurrency = viewModel.productPack.value.baseCurrency
            let productId = viewModel.productPack.value.productId
            destinationVC.title = button.tag == 0 ? "買入\(baseCurrency)" : "賣出\(baseCurrency)"
            // MARK: Pass Product Coin Code / Pair
            destinationVC.productPack = viewModel.productPack.value
            destinationVC.product = [
                "coinCode": baseCurrency,
                "pair": productId
            ]
            
            print("♥️ baseCurrency: \(baseCurrency), productId: \(productId)")
        }
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
            headerView.selectedCoin = viewModel.productPack.value.baseCurrency
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
            
            cell.dayArray = newDayArr.compactMap({ $0.averagePrice })
            cell.weekArray = newWeekArr.compactMap({ $0.averagePrice })
            cell.monthArray = newMonthArr.compactMap({ $0.averagePrice })
            cell.threeMonthArray = newThreeMonthArr.compactMap({ $0.averagePrice })
            cell.yearArray = newYearArr.compactMap({ $0.averagePrice })
            cell.allArray = newAllArr.compactMap({ $0.averagePrice })
            
            cell.dayTimeArray = newDayArr.compactMap({ $0.timestamp })
            cell.weekTimeArray = newWeekArr.compactMap({ $0.timestamp })
            cell.monthTimeArray = newMonthArr.compactMap({ $0.timestamp })
            cell.threeMonthTimeArray = newThreeMonthArr.compactMap({ $0.timestamp })
            cell.yearTimeArray = newYearArr.compactMap({ $0.timestamp })
            cell.allTimeArray = newAllArr.compactMap({ $0.timestamp })
            
            cell.setChartView(dataArray: cell.dayArray)
            
            return cell
            
        default:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            let coinCode = viewModel.productPack.value.baseCurrency
            if let data = viewModel.historyDataSource.value, data.count > 0 {
                cell.updateCell(data: data[indexPath.row], coinCode: coinCode)
            } else {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell
                else { fatalError("Unable to generate Table View Cell") }
                return cell
            }
            
            return cell
        }
    }
}

/*
 //        viewModel.getYearCandles { [weak self] extractedCandles in
 //             print("🟤 1 Year Candles Count: \(extractedCandles.count)")
 //             print("🟤 1 Year Candles: \(extractedCandles)")
 //            self?.newYearArr = extractedCandles
 //        }
 //
 //        viewModel.getAllCandles { [weak self] extractedCandles in
 //             print("🟣 All Candles Count: \(extractedCandles.count)")
 //             print("🟣 All Candles: \(extractedCandles)")
 //            self?.newAllArr = extractedCandles
 //        }
 */
