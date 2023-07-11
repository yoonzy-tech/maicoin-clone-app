//
//  CoinbaseService+Refactor.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/11.
//

import Foundation
import CryptoKit

struct AuthOutput {
    var timestamp: String
    var signature: String
}

extension CoinbaseService {
    
    func getAuthOutput(requestPath: String, httpMethod: String) -> AuthOutput {
        let date = Date().timeIntervalSince1970
        let cbAccessTimestamp = String(date)
        let secret = secret
        let requestPath = requestPath
        let httpMethod = httpMethod
        let message = "\(cbAccessTimestamp)\(httpMethod)\(requestPath)"
        
        guard let keyData = Data(base64Encoded: secret) else {
            fatalError("Failed to decode secret as base64")
        }
        
        let hmac = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: SymmetricKey(data: keyData))
        
        let cbAccessSign = hmac.withUnsafeBytes { macBytes -> String in
            let data = Data(macBytes)
            return data.base64EncodedString()
        }
        
        return AuthOutput(timestamp: cbAccessTimestamp, signature: cbAccessSign)
    }
    
    func fetchData<T: Codable>(api: CoinbaseApi, authRequired: Bool,
                               requestPath: String = "",
                               httpMethod: HttpMethod = .GET,
                               httpBody: String = "",
                               completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let url = URL(string: api.path) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if authRequired {
            let authOutput = getAuthOutput(requestPath: requestPath, httpMethod: httpMethod.rawValue)
            // print("Auth Output: \(authOutput)")
            request.addValue(apiKey, forHTTPHeaderField: "cb-access-key")
            request.addValue(passPhrase, forHTTPHeaderField: "cb-access-passphrase")
            request.addValue(authOutput.timestamp, forHTTPHeaderField: "cb-access-timestamp")
            request.addValue(authOutput.signature, forHTTPHeaderField: "cb-access-sign")
        }
        request.httpMethod = httpMethod.rawValue
        
        if httpMethod == .POST {
            request.httpBody = httpBody.data(using: .utf8)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(T.self, from: data)
                // print("📱 Response: \(response)")
                completion(.success(response))
            } catch {
                let response = String(data: data, encoding: String.Encoding.utf8) as Any
                print("API Error Response: \(response)")
                print("Error decoding data: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

extension CoinbaseService {
    func getAccounts(completion: @escaping ([Account]) -> Void) {
        fetchData(api: .accounts, authRequired: true, requestPath: "/accounts") { (result: Result<[Account], Error>) in
            switch result {
            case .success(let accounts):
                completion(accounts)
            case .failure(let error):
                print("Error in Accounts API: \(error)")
            }
        }
    }
    
    func getExchangeRate(for currency: String = "USD", to quote: String = "TWD", completion: @escaping (Double) -> Void) {
        fetchData(api: .exchangeRate(currency: currency), authRequired: false) { (result: Result<ExchangeRates, Error>) in
            switch result {
            case .success(let exchangeRates):
                // Only send the rate converting to TWD
                guard let rateToTWD = exchangeRates.data.rates[quote]?.convertToDouble() else {
                    print("No exchange rate found for \(currency) to \(quote)")
                    return
                }
                completion(rateToTWD)
            case .failure(let error):
                print("Error in Exchange Rate API: \(error)")
            }
        }
    }
    
    func getTradingPairs(completion: @escaping ([TradingPair]) -> Void) {
        fetchData(api: .allTradingPairs, authRequired: false) { (result: Result<[TradingPair], Error>) in
            switch result {
            case .success(let tradingPairs):
                completion(tradingPairs)
            case .failure(let error):
                print("Error in Trading Pairs API: \(error)")
            }
        }
    }
    
    func getCurrencyInfo(currency: String, completion: @escaping (CurrencyInfo) -> Void) {
        fetchData(api: .currencyDetail(currency: currency), authRequired: false) { (result: Result<CurrencyInfo, Error>) in
            switch result {
            case .success(let currencyInfo):
                completion(currencyInfo)
            case .failure(let error):
                print("Error in Currencies API for \(currency): \(error)")
            }
        }
    }
    
    func getProductStats(productId: String, completion: @escaping (ProductStats) -> Void) {
        fetchData(api: .productStats(productId: productId), authRequired: false) { (result: Result<ProductStats, Error>) in
            switch result {
            case .success(let produdctStats):
                completion(produdctStats)
            case .failure(let error):
                print("Error in Product Stats API for \(productId): \(error)")
            }
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
}
