//
//  HomeViewModel.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/29.
//

import Foundation

struct ProductPack {
    var baseCurrency: String = ""
    var productId: String = ""
    var baseCurrencyName: String = ""
    var fluctuateRate: Double = 0
    var averagePrice: Double = 0
}

class HomeViewModel {
    
    var accountTotalBalance: ObservableObject<Double> = ObservableObject(0)
    
    // baseCurrency, productId, baseCurrencyName, fluctuateRate, averagePrice
    var usdProductPacks: ObservableObject<[ProductPack]> = ObservableObject([])
}

extension HomeViewModel {
    func getAccountsTotalBalanceNew(completion: @escaping () -> Void) {
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
                // print("Total Balance: \(totalBalance)")
                completion()
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
                // print("😇 Updated Product Pack: \(updatedProduct)")
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
                // print("🤡 Updated Product Pack: \(updatedProduct)")
                group.leave()
            }
            
        }
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func prepareHomepageData(completion: (() -> Void)? = nil) {
        
        getAccountsTotalBalanceNew {
            self.getUSDTradingPairsNEW {
                self.getCurrencyNamesNEW {
                    self.getUSDProductsStatsNEW {
                        // print("💀 USD Product Pack: \(self.usdProductPacks.value)")
                        completion?()
                    }
                }
            }
        }
    }
}
