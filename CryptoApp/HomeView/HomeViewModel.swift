//
//  HomeViewModel.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/29.
//

import Foundation

// State Management

class HomeViewModel {
    
    var accountTotalBalance: ObservableObject<Double> = ObservableObject(0)
   
    // CoinCode, Pair ID: ("BTC", "BTC-USD")
    var usdTradingPairs: ObservableObject<[(String, String)]> = ObservableObject([])
    
    // CoinCode, Fullname: ("BTC", "Bitcoin")
    var currencyNames: ObservableObject<[(String, String)]> = ObservableObject([])
    
    // Rate, AvgPrice
    var fluctuateRateAvgPrice: ObservableObject<[(Double, Double)]> = ObservableObject([])
    
}

extension HomeViewModel {
    
    func getUSDTradingPairs() {
        CoinbaseService.shared.fetchTradingPairs { [weak self] tradingPairs in
            let USDPairs = tradingPairs.filter { tradingPair in
                return String(tradingPair.id.suffix(3)) == CurrencyName.USD.rawValue
                && tradingPair.auctionMode == false
                && tradingPair.status == "online"
            }
            
            let newUSDPairs = USDPairs.compactMap { product in
                return (product.baseCurrency, product.id)
            }
            // print("USD Curreny Pairs (Array): \(USDPairs)")
            self?.usdTradingPairs.value = newUSDPairs.sorted(by: { $0 < $1 })
        }
        
    }

    func getAccountsTotalBalance() {
        CoinbaseService.shared.fetchAccounts { [weak self] accounts in
             // print("Account: \(accounts)")
            self?.accountTotalBalance.value = Double(accounts.first { $0.currency == "USD" }?.balance ?? "") ?? 0
            // guard let accountTotalBalance = self?.accountTotalBalance else { return }
            // print("Total Account Balance: \(accountTotalBalance.value)")
        }
    }

    func getUSDPairsProductFluctRateAvgPrice() {
        // print("USD Pair List: \(usdTradingPairs.value)")
        fluctuateRateAvgPrice.value = []
        usdTradingPairs.value.forEach { productID in
            
            CoinbaseService.shared.fetchProductStats(productID: productID.1) { [weak self] productStats in
                // print("\(productID.0): \(productStats)"
                let lastPrice = productStats.last
                let openPrice = productStats.open
                let flucRate = ((Double(lastPrice) ?? 0) - (Double(openPrice) ?? 0)) / (Double(lastPrice) ?? 0) * 100
                
                let highPrice = productStats.high
                let lowPrice = productStats.low
                let avgPrice = ((Double(highPrice) ?? 0) + (Double(lowPrice) ?? 0)) / 2
                
                self?.fluctuateRateAvgPrice.value.append((flucRate, avgPrice))
            }
        }
        // print(fluctuateRateAvgPrice.value)
    }
    
    func getCurrencyNames() {
        currencyNames.value = []
        usdTradingPairs.value.forEach { currency in
            
            CoinbaseService.shared.fetchCurrencyDetail(currencyID: currency.0) { [weak self] currencyInfo in
                self?.currencyNames.value.append((currencyInfo.id, currencyInfo.name))
            }
        }
         // print(currencyNames.value)
    }
}
