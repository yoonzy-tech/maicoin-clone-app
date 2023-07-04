//
//  Constants.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/30.
//

import Foundation

enum AppColor: String {
    case red = "#EE5455"
    case green = "#0FBA85"
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

enum CoinbaseApi {
    case accounts
    case allTradingPairs
    case profile
    case allCurrenciesDetail
    case currencyDetail(currencyID: String)
    case productStats(productID: String)
    case allOrders(limit: Int, status: String, productID: String)
    case allCandles(productID: String, granularity: String, start: String, end: String)
    case exchangeRate
    
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
        case .allOrders(limit: let limit, status: let status, productID: let productID):
            return "\(baseURL)/orders?limit=\(limit)&status=\(status)&product_id=\(productID)"
        case .allCandles(productID: let productID, granularity: let granularity, start: let start, end: let end):
                return "https://api-public.sandbox.pro.coinbase.com/products/\(productID)/candles?granularity=\(granularity)&start=\(start)&end=\(end)"
        case .exchangeRate:
            return "https://api.coinbase.com/v2/exchange-rates"
        }
    }
}
