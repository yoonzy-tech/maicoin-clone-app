//
//  ViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/28.
//

import UIKit

class HomeViewController: UIViewController {

    var usdCurrencyPairs: [CurrencyPair] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.products,
                                              authRequired: false) { (products: [CurrencyPair]) in
            
            let USDPairs = products.filter { currencyPair in
                return String(currencyPair.id.suffix(3)) == "USD"
            }
            
            print("USD Curreny Pairs (Array): \(USDPairs)")
        }
        
        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.profile,
                                              authRequired: true,
                                              requestPath: RequestPath.profile,
                                              httpMethod: HttpMethod.get) { (profiles: [Profile]) in
            
            guard let profile = profiles.first else { return } // 一個帳號怎樣都只有一個Profile, 但API會吐Array
            
            print("Profile: \(profile)")
        }

        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.accounts,
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
    
}
