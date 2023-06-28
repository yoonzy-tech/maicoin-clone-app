//
//  Products.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/28.
//

import Foundation

struct CurrencyPair: Codable {
    
    let id, baseCurrency, quoteCurrency, quoteIncrement: String
    let baseIncrement, displayName, minMarketFunds: String
    let marginEnabled, postOnly, limitOnly, cancelOnly: Bool
    let status, statusMessage: String
    let tradingDisabled, fxStablecoin: Bool
    let maxSlippagePercentage: String
    let auctionMode: Bool
    let highBidLimitPercentage: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case baseCurrency = "base_currency"
        case quoteCurrency = "quote_currency"
        case quoteIncrement = "quote_increment"
        case baseIncrement = "base_increment"
        case displayName = "display_name"
        case minMarketFunds = "min_market_funds"
        case marginEnabled = "margin_enabled"
        case postOnly = "post_only"
        case limitOnly = "limit_only"
        case cancelOnly = "cancel_only"
        case status
        case statusMessage = "status_message"
        case tradingDisabled = "trading_disabled"
        case fxStablecoin = "fx_stablecoin"
        case maxSlippagePercentage = "max_slippage_percentage"
        case auctionMode = "auction_mode"
        case highBidLimitPercentage = "high_bid_limit_percentage"
    }
}
