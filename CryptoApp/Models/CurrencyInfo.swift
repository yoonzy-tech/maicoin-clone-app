//
//  CurrenciesModel.swift
//  DoubleCoin
//
//  Created by Ruby Chew on 2023/6/29.
//

import Foundation

// MARK: - Currencies

struct CurrencyInfo: Codable {
  let id, name, minSize: String
  let status: Status
  let message, maxPrecision: String
  let convertibleTo: [String]
  let details: Details
  let defaultNetwork: String
  let supportedNetworks: [SupportedNetwork]

  enum CodingKeys: String, CodingKey {
    case id, name
    case minSize = "min_size"
    case status, message
    case maxPrecision = "max_precision"
    case convertibleTo = "convertible_to"
    case details
    case defaultNetwork = "default_network"
    case supportedNetworks = "supported_networks"
  }
}

// MARK: - Details

struct Details: Codable {
  let type: TypeEnum
  let symbol: String?
  let networkConfirmations, sortOrder: Int?
  let cryptoAddressLink, cryptoTransactionLink: String?
  let pushPaymentMethods, groupTypes: [String]
  let displayName: String?
  let processingTimeSeconds: JSONNull?
  let minWithdrawalAmount: Double?
  let maxWithdrawalAmount: Int?

  enum CodingKeys: String, CodingKey {
    case type, symbol
    case networkConfirmations = "network_confirmations"
    case sortOrder = "sort_order"
    case cryptoAddressLink = "crypto_address_link"
    case cryptoTransactionLink = "crypto_transaction_link"
    case pushPaymentMethods = "push_payment_methods"
    case groupTypes = "group_types"
    case displayName = "display_name"
    case processingTimeSeconds = "processing_time_seconds"
    case minWithdrawalAmount = "min_withdrawal_amount"
    case maxWithdrawalAmount = "max_withdrawal_amount"
  }
}

enum TypeEnum: String, Codable {
  case crypto
  case fiat
}

enum Status: String, Codable {
  case delisted
  case online
}

// MARK: - SupportedNetwork

struct SupportedNetwork: Codable {
  let id, name: String
  let status: Status
  let contractAddress, cryptoAddressLink, cryptoTransactionLink: String
  let minWithdrawalAmount: Double
  let maxWithdrawalAmount, networkConfirmations: Int
  let processingTimeSeconds: JSONNull?

  enum CodingKeys: String, CodingKey {
    case id, name, status
    case contractAddress = "contract_address"
    case cryptoAddressLink = "crypto_address_link"
    case cryptoTransactionLink = "crypto_transaction_link"
    case minWithdrawalAmount = "min_withdrawal_amount"
    case maxWithdrawalAmount = "max_withdrawal_amount"
    case networkConfirmations = "network_confirmations"
    case processingTimeSeconds = "processing_time_seconds"
  }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    func hash(into hasher: inout Hasher) {
        // Implement the hash(into:) method
        hasher.combine(0) // Use a fixed hash value
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
