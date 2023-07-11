//
//  Constants.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/30.
//

import Foundation

enum AppColor: String {
    case red = "#EE5455"
    case green = "#03BB77"
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
    case currencyDetail(currency: String)
    case productStats(productId: String)
    case allOrders(limit: Int, status: String, productID: String)
    case createOrder
    case getOrder(orderID: String)
    case allCandles(productID: String, granularity: String, start: String, end: String)
    case exchangeRate(currency: String)
    
    private var baseURL: String {
        return "https://api-public.sandbox.pro.coinbase.com"
    }
    
    var path: String {
        switch self {
        case .accounts:
            return "\(baseURL)/accounts"
        case .allTradingPairs:
            return "\(baseURL)/products"
        case .productStats(productId: let productId):
            return "\(baseURL)/products/\(productId)/stats"
        case .profile:
            return "\(baseURL)/profiles?active"
        case .allCurrenciesDetail:
            return "\(baseURL)/currencies"
        case .currencyDetail(currency: let currency):
            return "\(baseURL)/currencies/\(currency)"
        case .allOrders(limit: let limit, status: let status, productID: let productID):
            return "\(baseURL)/orders?limit=\(limit)&status=\(status)&product_id=\(productID)"
        case .createOrder:
            return "\(baseURL)/orders"
        case .getOrder(orderID: let orderID):
            return "\(baseURL)/orders/\(orderID)"
        case .allCandles(productID: let productID,
                         granularity: let granularity,
                         start: let start,
                         end: let end):
                return "\(baseURL)/products/\(productID)/candles?granularity=\(granularity)&start=\(start)&end=\(end)"
        case .exchangeRate(currency: let currency):
            return "https://api.coinbase.com/v2/exchange-rates?currency=\(currency)"
        }
    }
}
