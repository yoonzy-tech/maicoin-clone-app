//
//  CoinMarketChartViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/30.
//

import UIKit

class MarketChartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        WebsocketService.shared.connect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WebsocketService.shared.disconnect()
    }
}
