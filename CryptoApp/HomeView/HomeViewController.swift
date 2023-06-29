//
//  ViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/28.
//

import UIKit

enum CurrencyName: String {
    case USD
}

class HomeViewController: UIViewController {

    var USDCurrencyPairs: [CurrencyPair] = []
    
    var USDProductList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUSDProductList()
        getAllProductStats()
    }
}

extension HomeViewController {
    func getUSDProductList() {
        CoinbaseService.shared.getApiResponseArray(api: CoinbaseApi.products,
                                                   authRequired: false) { [weak self] (products: [CurrencyPair]) in
            let USDPairs = products.filter { currencyPair in
                return String(currencyPair.id.suffix(3)) == CurrencyName.USD.rawValue
            }
            
            USDPairs.forEach { [weak self] product in
                self?.USDProductList.append(product.id)
            }
        }
    }
    
    func getCurrencyInfo(currencyID: String) -> [String] {
        // Get coin full name
        
        var currencyNames: [String] = []
        
        CoinbaseService.shared.getApiSingleResponse(api: .currencies,
                                                    param: "\(currencyID)",
                                                   authRequired: false) { (currencies: [CurrencyInfo]) in
            currencies.forEach { currencyInfo  in
                currencyNames.append(currencyInfo.name)
            }
        }
        print(currencyNames)
        return currencyNames
    }
    
    func getAccountTotalBalance() {
        CoinbaseService.shared.getApiResponseArray(api: CoinbaseApi.accounts,
                                                   authRequired: true,
                                                   requestPath: RequestPath.accounts,
                                                   httpMethod: HttpMethod.get) { (accounts: [Account]) in
            let accountTotalBalance = accounts.reduce(0) { partialResult, account in
                if let balance = Double(account.balance) {
                    // print("\(account.currency): \(balance)")
                    return partialResult + balance
                } else {
                    print("Invalid balance")
                    return 0
                }
            }
            print("Total Account Balance: \(accountTotalBalance)")
        }
    }
    
    func getAllProductStats() {
        // Get product stats (percentage, 24hr avg price)
        print("USD Product List: \(USDProductList)")
        
        USDProductList.forEach { productID in
            
            CoinbaseService.shared.getApiSingleResponse(api: CoinbaseApi.products,
                                                        param: "/\(productID)/stats",
                                                        authRequired: false) { (productStats: ProductStats) in
                print("\(productID): \(productStats)")
                
                let lastPrice = productStats.last
                let openPrice = productStats.open
                let flucRate = ((Double(lastPrice) ?? 0) - (Double(openPrice) ?? 0)) / (Double(lastPrice) ?? 0)
                let roundedRate = (flucRate * 100).rounded() / 100
                
                print("FlucRate: \(roundedRate), LastPrice: \(lastPrice.formatAsAccountNumber())")
            }
        }
    }
}
