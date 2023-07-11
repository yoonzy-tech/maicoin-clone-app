//
//  HomeViewModel.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/29.
//

import Foundation

class HomeViewModel {
    
    var accountTotalBalance: ObservableObject<Double> = ObservableObject(0)
    
    // coinCode, productId, coinName, rate, price
    var usdProductPacks: ObservableObject<[ProductPack]> = ObservableObject([])
   
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

    func getUSDPairsProductFluctRateAvgPrice() {
        // print("USD Pair List: \(usdTradingPairs.value)")
        fluctuateRateAvgPrice.value = []
        usdTradingPairs.value.forEach { productID in
            
            CoinbaseService.shared.fetchProductStats(productID: productID.1) { [weak self] productStats in
                // print("\(productID.0): \(productStats)"
                let lastPrice = Double(productStats.last) ?? 0
                let openPrice = Double(productStats.open) ?? 0
                let flucRate = (lastPrice - openPrice) / lastPrice * 100
                
                let highPrice = Double(productStats.high) ?? 0
                let lowPrice = Double(productStats.low) ?? 0
                let avgPrice = (highPrice + lowPrice) / 2
                
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
    
    func getAccountsTotalBalanceNew() {
        CoinbaseService.shared.getAccounts { accounts in
            var totalBalance: Double = 0
            
            let group = DispatchGroup()
            
            accounts.forEach { account in
                group.enter()
                CoinbaseService.shared.getExchangeRate(for: account.currency) { rate in
                    defer {
                        group.leave()
                    }
                    let accountBalance = account.balance.convertToDouble()
                    let balanceInTWD = accountBalance * rate
                    totalBalance += balanceInTWD
                }
            }
            
            group.notify(queue: .main) {
                self.accountTotalBalance.value = totalBalance
                print("Total Balance: \(totalBalance)")
            }
        }
    }
    
    func getUSDTradingPairsNEW(completion: @escaping () -> Void) {
        CoinbaseService.shared.getTradingPairs { tradingPairs in
            let usdTradingPairs = tradingPairs.filter { tradingPair in
                return tradingPair.quoteCurrency == "USD"
                && tradingPair.auctionMode == false
                && tradingPair.status == "online"
            }
            let usdProductPacks = usdTradingPairs.compactMap { tradingPairs in
                return ProductPack(baseCurrency: tradingPairs.baseCurrency,
                                   productId: tradingPairs.id)
            }.sorted { $0.baseCurrency < $1.baseCurrency }
            
            self.usdProductPacks.value = usdProductPacks
            // print("USD Product Packs: \(usdProductPacks)")
            completion()
        }
    }
    
    func getCurrencyNamesNEW(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        usdProductPacks.value.enumerated().forEach { index, productPack in
            group.enter()
            CoinbaseService.shared.getCurrencyInfo(currency: productPack.baseCurrency) { [weak self] currencyInfo in
                
                // Update the Product Pack
                var updatedProduct = productPack
                updatedProduct.baseCurrencyName = currencyInfo.name
                self?.usdProductPacks.value[index] = updatedProduct
                print("😇 Updated Product Pack: \(updatedProduct)")
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func getUSDProductsStatsNEW(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        usdProductPacks.value.enumerated().forEach { index, productPack in
            group.enter()
            CoinbaseService.shared.getProductStats(productId: productPack.productId) { [weak self] productStats in
                
                let lastPrice = Double(productStats.last) ?? 0
                let openPrice = Double(productStats.open) ?? 0
                let flucRate = (lastPrice - openPrice) / lastPrice * 100
                
                let highPrice = Double(productStats.high) ?? 0
                let lowPrice = Double(productStats.low) ?? 0
                let avgPrice = (highPrice + lowPrice) / 2
                
                // Update the Product Pack
                var updatedProduct = productPack
                updatedProduct.fluctuateRate = flucRate
                updatedProduct.averagePrice = avgPrice
                self?.usdProductPacks.value[index] = updatedProduct
                print("🤡 Updated Product Pack: \(updatedProduct)")
                group.leave()
            }
            
        }
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func prepareHomepageData(completion: @escaping () -> Void) {
        getUSDTradingPairsNEW {
            self.getCurrencyNamesNEW {
                self.getUSDProductsStatsNEW {
                    print("💀 USD Product Pack: \(self.usdProductPacks.value)")
                    completion()
                }
            }
        }
    }
}
