//
//  Account.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/28.
//

import Foundation

struct Account: Codable {
    let id: String
    let currency: String
    let balance: String
    let hold: String
    let available: String
    let profileID: String
    let tradingEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case currency
        case balance
        case hold
        case available
        case profileID = "profile_id"
        case tradingEnabled = "trading_enabled"
    }
}
