//
//  Orders.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/1.
//

import Foundation

struct Order: Codable {
    let id: String
    let price: String?
    let size: String
    let productId: String
    let profileId: String?
    let side: String
    let funds: String?
    let specifiedFunds: String?
    let type: String
    let timeInForce: String?
    let postOnly: Bool
    let createdAt: String
    let doneAt: String?
    let doneReason: String?
    let fillFees: String
    let filledSize: String
    let executedValue: String
    let marketType: String?
    let status: String
    let settled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case price
        case size
        case productId = "product_id"
        case profileId = "profile_id"
        case side
        case funds
        case specifiedFunds = "specified_funds"
        case type
        case timeInForce = "time_in_force"
        case postOnly = "post_only"
        case createdAt = "created_at"
        case doneAt = "done_at"
        case doneReason = "done_reason"
        case fillFees = "fill_fees"
        case filledSize = "filled_size"
        case executedValue = "executed_value"
        case marketType = "market_type"
        case status
        case settled
    }
}
