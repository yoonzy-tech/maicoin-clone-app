//
//  Profile.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/28.
//

import Foundation

struct Profile: Codable {
    let id: String
    let userId: String
    let name: String
    let active: Bool
    let isDefault: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case active
        case isDefault = "is_default"
        case createdAt = "created_at"
    }
}
