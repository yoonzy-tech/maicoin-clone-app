//
//  Orders.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/1.
//

import Foundation

struct Order: Codable {
  let id, price, size, productID: String
  let profileID, side, type, timeInForce: String
  let createdAt, doneAt, doneReason: String
  let fillFees, filledSize, executedValue, marketType: String
  let status: String
  let fundingCurrency: String?
  let postOnly, settled: Bool

  enum CodingKeys: String, CodingKey {
    case id, price, size
    case productID = "product_id"
    case profileID = "profile_id"
    case side, type
    case timeInForce = "time_in_force"
    case postOnly = "post_only"
    case createdAt = "created_at"
    case doneAt = "done_at"
    case doneReason = "done_reason"
    case fillFees = "fill_fees"
    case filledSize = "filled_size"
    case executedValue = "executed_value"
    case marketType = "market_type"
    case status, settled
    case fundingCurrency = "funding_currency"
  }
}
