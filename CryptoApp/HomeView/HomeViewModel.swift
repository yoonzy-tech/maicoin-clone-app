//
//  HomeViewModel.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/29.
//

import Foundation

// State Management

/* States
 [] Account Balance Total: Sum up all the balance in Accounts under this User
 [] Coin Code: Products API, id ending up with USD
 [] Coin Full Name (ZH-TW or ENG): Currencies API, name
 [] Coin Fluct Rate
 [] Coin Past 24H Avg Price (where to get)
 */

class HomeViewModel {
    
    var accountTotalBalance: ObservableObject<Double> = ObservableObject(0)
   
    var USDProductList: ObservableObject<[String]> = ObservableObject([])
    
    var currencyNames: ObservableObject<[(String, String)]> = ObservableObject([])
    
}

extension HomeViewModel {
    func getUSDProductList() {
        CoinbaseService.shared.getApiResponseArray(api: CoinbaseApiUrl.products,
                                                   authRequired: false) { [weak self] (products: [CurrencyPair]) in
            let USDPairs = products.filter { currencyPair in
                return String(currencyPair.id.suffix(3)) == CurrencyName.USD.rawValue
            }

            USDPairs.forEach { [weak self] product in
                self?.USDProductList.value.append(product.id)
            }
        }
    }
    
//    func getCurrencyInfo(currencyID: String) -> [(String, String)] {
//        // Get coin full name (CoinCode, CoinFullName)
//        CoinbaseService.shared.getApiSingleResponse(api: .currencies,
//                                                    param: "\(currencyID)",
//                                                   authRequired: false) { (currencies: [CurrencyInfo]) in
//            currencies.forEach { currencyInfo  in
//                self.currencyNames.value.append((currencyInfo.id, currencyInfo.name))
//            }
//        }
//        print(currencyNames.value)
//        return currencyNames.value
//    }
//
//    func getAccountsTotalBalance() {
//        CoinbaseService.shared.getApiResponseArray(api: CoinbaseApiUrl.accounts,
//                                                   authRequired: true,
//                                                   requestPath: RequestPath.accounts,
//                                                   httpMethod: HttpMethod.get) { [weak self] (accounts: [Account]) in
//            self?.accountTotalBalance.value = accounts.reduce(0) { partialResult, account in
//                if let balance = Double(account.balance) {
//                    return partialResult + balance
//                } else {
//                    print("Invalid balance")
//                    return 0
//                }
//            }.roundToDecimal(2)
//            // print("Total Account Balance: \(accountTotalBalance)")
//        }
//    }
//
//    func getAllProductStats() {
//        // Get product stats (percentage, 24hr avg price)
//        print("USD Product List: \(USDProductList)")
//
//        USDProductList.value.forEach { productID in
//
//            CoinbaseService.shared.getApiSingleResponse(api: CoinbaseApiUrl.products,
//                                                        param: "/\(productID)/stats",
//                                                        authRequired: false) { (productStats: ProductStats) in
//                print("\(productID): \(productStats)")
//
//                let lastPrice = productStats.last
//                let openPrice = productStats.open
//                let flucRate = ((Double(lastPrice) ?? 0) - (Double(openPrice) ?? 0)) / (Double(lastPrice) ?? 0)
//
//                print("FlucRate: \(flucRate.roundToDecimal(2)), LastPrice: \(lastPrice.formatAsAccountNumber())")
//            }
//        }
//    }
}
