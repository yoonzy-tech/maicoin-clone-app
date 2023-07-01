//
//  MarketChartViewModel.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/1.
//

import Foundation

class MarketChartViewModel {
    
    func getProductOrders(productID: String) {
        CoinbaseService.shared.fetchProductCandles(productID: productID) { candles in
            print("Candles: \(candles)")
        }
    }
    
    func getProductCandles(productID: String = "BTC-USD") {
        CoinbaseService.shared.fetchProductOrders(productID: productID) { orders in
            print("Orders: \(orders)")
        }
    }
    
}
