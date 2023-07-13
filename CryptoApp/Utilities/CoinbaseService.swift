//
//  CoinbaseService.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/28.
//

import Foundation
import Kingfisher

extension CoinbaseService {
    // MARK: Use Semaphore
    func getExchangeRate(from base: String = "USD", to currency: String = "TWD") -> Double? {
        guard let response: ExchangeRates? = getApiResponseSemaphore(api: .exchangeRate(currency: base),
                                                                        authRequired: false) else {
            print("Failed to fetch current \(currency) exchange rate ")
            return nil
        }
        
        guard let rateToTWD = response?.data.rates[currency] else {
            print("Unable to get the exchange rate to \(currency)")
            return nil
        }
        
        return Double(rateToTWD) ?? 0
    }
    
    func fetchAccountsNew() -> [Account]? {
        guard let accounts: [Account]? = getApiResponseSemaphore(api: .accounts,
                                                                    authRequired: true,
                                                                    requestPath: "/accounts", httpMethod: .GET) else {
            print("Failed to fetch accounts.")
            return nil
        }
        return accounts
    }
    
    func fetchUserProfileNew() -> Profile? {
        let profiles: [Profile]? = getApiResponseSemaphore(api: .profile,
                                                              authRequired: true,
                                                              requestPath: "/profiles?active",
                                                              httpMethod: .GET)
        guard let profile = profiles?.first else {
            print("Failed to get user profile.")
            return nil
        }
        return profile
    }
    
    func getIconUrl(imageView: UIImageView, for coinCode: String, style: String = "icon") {
        let lowercased = coinCode.lowercased()
        let coinIconUrl = "https://cryptoicons.org/api/\(style)/\(lowercased)/200"
        imageView.kf.setImage(with: URL(string: coinIconUrl), placeholder: UIImage(named: "coin placeholder"))
    }
    
    func fetchCurrencyDetailNew(currencyID: String) -> CurrencyInfo? {
        guard let currencyInfo: CurrencyInfo? = getApiResponseSemaphore(
            api: .currencyDetail(currency: currencyID), authRequired: false) else {
            print("Failed to get \(currencyID) coin icon")
            return nil
        }
        return currencyInfo
    }
    
    func createOrders( // realtime rate, price: String = "35000.99",
        size: String, // user entered value
        side: String, // actionType
        productId: String) -> String? {
            
            let httpBody = """
        {
            "type": "market",
            "size": "\(size)",
            "side": "\(side)",
            "product_id": "\(productId)",
            "time_in_force": "FOK"
        }
        """
            print("😎 Body: \(httpBody)")
            guard let order: Order? = getApiResponseSemaphore(api: .createOrder,
                                                                 authRequired: true,
                                                                 requestPath: "/orders",
                                                                 httpMethod: .POST,
                                                                 httpBody: httpBody) else {
                print("Failed to get order response")
                return nil
            }
            
            return order?.id
        }
    
    func fetchCompletedOrderNew(orderID: String) -> Order? {
        
        guard let order: Order? = getApiResponseSemaphore(api: .getOrder(orderID: orderID),
                                                             authRequired: true,
                                                             requestPath: "/orders/" + orderID,
                                                             httpMethod: .GET)
        else {
            print("Failed to get the transaction details")
            return nil
        }
        return order
    }
    
    func fetchProductOrdersNew(productID: String, status: String = "done", limit: Int = 5) -> [Order]? {
        
        guard let histories: [Order]? = getApiResponseSemaphore(
            api: .allOrders(limit: limit, status: status, productId: productID),
            authRequired: true,
            requestPath: "/orders?limit=\(limit)&status=\(status)&product_id=\(productID)",
            httpMethod: .GET) else {
            print("Failed to get the \(productID) product order details")
            return nil
        }
        
        return histories
    }
}
