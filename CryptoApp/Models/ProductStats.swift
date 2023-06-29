//
//  ProductStats.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/29.
//

import Foundation

struct ProductStats: Codable {
    let open: String
    let high: String
    let low: String
    let last: String
    let volume: String
    let volume30day: String?
    
    enum CodingKeys: String, CodingKey {
        case open
        case high
        case low
        case last
        case volume
        case volume30day = "volume_30day"
    }
}
