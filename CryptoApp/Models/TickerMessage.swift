//
//  TickerMessage.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/1.
//

import Foundation

struct TickerMessage: Codable {
    let type: String
    let sequence: Int?
    let productId: String?
    let price: String?
    let open24h: String?
    let volume24h: String?
    let low24h: String?
    let high24h: String?
    let volume30d: String?
    let bestBid: String?
    let bestBidSize: String?
    let bestAsk: String?
    let bestAskSize: String?
    let side: String?
    let time: String?
    let tradeId: Int?
    let lastSize: String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case sequence
        case productId = "product_id"
        case price
        case open24h = "open_24h"
        case volume24h = "volume_24h"
        case low24h = "low_24h"
        case high24h = "high_24h"
        case volume30d = "volume_30d"
        case bestBid = "best_bid"
        case bestBidSize = "best_bid_size"
        case bestAsk = "best_ask"
        case bestAskSize = "best_ask_size"
        case side
        case time
        case tradeId = "trade_id"
        case lastSize = "last_size"
    }
}
