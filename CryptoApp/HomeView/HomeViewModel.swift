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
        guard let accounts = CoinbaseService.shared.fetchAccountsNew() else {
            print("Fail to get accounts data")
            return
        }
        
        let totalBalance = accounts.reduce(0) { partialResult, account in
            if let rate = CoinbaseService.shared.getExchangeRate(from: account.currency) {
                let currencyBalance = account.balance.convertToDouble()
                return partialResult + (currencyBalance * rate)
            } else {
                print("Failed to get exchange for \(account.currency) to TWD")
                return partialResult
            }
        }
        
        self.accountTotalBalance.value = totalBalance
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
    }
    
    func getCurrencyNames() {
        currencyNames.value = []
        usdTradingPairs.value.forEach { [weak self] currency in
            let currencyInfo = CoinbaseService.shared.fetchCurrencyDetailNew(currencyID: currency.0)
            let coinId = currencyInfo?.id ?? ""
            let coinName = currencyInfo?.name ?? ""
            self?.currencyNames.value.append((coinId, coinName))
        }
    }
}
