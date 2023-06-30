//
//  Constants.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/30.
//

import Foundation

enum AppColor: String {
    case red = "#EE5455"
}

let coinCodeToZHTWName: [String: String] = [
    "BTC": "比特幣",
    "USDT": "泰達幣",
    "LINK": "Chainlink"
]

enum HttpMethod: String {
    case GET
    case POST
}

enum CoinbaseRequestPath: String {
    case none
    case accounts = "/accounts"
    case profile = "/profiles?active"
}

enum CoinbaseApi {
    case accounts
    case allTradingPairs
    case profile
    case allCurrenciesDetail
    case currencyDetail(currencyID: String)
    case productStats(productID: String)
    
    private var baseURL: String {
        return "https://api-public.sandbox.pro.coinbase.com"
    }
    
    var path: String {
        switch self {
        case .accounts:
            return "\(baseURL)/accounts"
        case .allTradingPairs:
            return "\(baseURL)/products"
        case .productStats(productID: let productID):
            return "\(baseURL)/products/\(productID)/stats"
        case .profile:
            return "\(baseURL)/profiles?active"
        case .allCurrenciesDetail:
            return "\(baseURL)/currencies"
        case .currencyDetail(currencyID: let currencyID):
            return "\(baseURL)/currencies/\(currencyID)"
        }
    }
}
