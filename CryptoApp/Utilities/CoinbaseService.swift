//
//  CoinbaseService.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/28.
//

import Foundation
import CryptoKit
import Alamofire

enum CoinbaseApi: String {
    case products = "https://api-public.sandbox.pro.coinbase.com/products"
    case accounts  = "https://api-public.sandbox.pro.coinbase.com/accounts"
    case profile  = "https://api-public.sandbox.pro.coinbase.com/profiles?active"
    case currencies = "https://api-public.sandbox.pro.coinbase.com/currencies"
}

enum RequestPath: String {
    case none
    case accounts = "/accounts"
    case profile = "/profiles?active"
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}

final class CoinbaseService {
    
    static let shared = CoinbaseService()
    
    private init() {}
    
    func getTimestampSignature(requestPath: String,
                               method: String,
                               body: String) -> (String, String) {
        
        let date = Date().timeIntervalSince1970
        let cbAccessTimestamp = String(date)
        let secret = secret
        let requestPath = requestPath
        let body = body
        let method = method
        let message = "\(cbAccessTimestamp)\(method)\(requestPath)\(body)"

        guard let keyData = Data(base64Encoded: secret) else {
            fatalError("Failed to decode secret as base64")
        }

        let hmac = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: SymmetricKey(data: keyData))

        let cbAccessSign = hmac.withUnsafeBytes { macBytes -> String in
            let data = Data(macBytes)
            return data.base64EncodedString()
        }
        // print(cbAccessTimestamp)
        // print(cbAccessSign)
        
        return (cbAccessTimestamp, cbAccessSign)
    }
    
    func getApiResponseArray<T: Codable>(api: CoinbaseApi,
                                         param: String = "",
                                         authRequired: Bool,
                                         requestPath: RequestPath = .none,
                                         httpMethod: HttpMethod = .get,
                                         body: String = "",
                                         completion: (([T]) -> Void)? = nil) {
        
        let semaphore = DispatchSemaphore(value: 0)
        guard let url = URL(string: api.rawValue + param) else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if authRequired {
            let timestampSignature = getTimestampSignature(requestPath: requestPath.rawValue,
                                                           method: httpMethod.rawValue,
                                                           body: body)
            
            request.addValue(apiKey, forHTTPHeaderField: "cb-access-key")
            request.addValue(passPhrase, forHTTPHeaderField: "cb-access-passphrase")
            request.addValue(timestampSignature.0, forHTTPHeaderField: "cb-access-timestamp")
            request.addValue(timestampSignature.1, forHTTPHeaderField: "cb-access-sign")
        }
        
        request.httpMethod = httpMethod.rawValue
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode([T].self, from: data)
                // print("Response: \(response)")
                completion?(response)
            } catch {
                print("Error decoding data: \(error)")
            }
            
            // print(String(data: data, encoding: .utf8)!)
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
    func getApiSingleResponse<T: Codable>(api: CoinbaseApi,
                                          param: String = "",
                                          authRequired: Bool,
                                          requestPath: RequestPath = .none,
                                          httpMethod: HttpMethod = .get,
                                          body: String = "",
                                          completion: ((T) -> Void)? = nil) {
        
        let semaphore = DispatchSemaphore(value: 0)
        guard let url = URL(string: api.rawValue + param) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if authRequired {
            let timestampSignature = getTimestampSignature(requestPath: requestPath.rawValue,
                                                           method: httpMethod.rawValue,
                                                           body: body)
            
            request.addValue(apiKey, forHTTPHeaderField: "cb-access-key")
            request.addValue(passPhrase, forHTTPHeaderField: "cb-access-passphrase")
            request.addValue(timestampSignature.0, forHTTPHeaderField: "cb-access-timestamp")
            request.addValue(timestampSignature.1, forHTTPHeaderField: "cb-access-sign")
        }
        
        request.httpMethod = httpMethod.rawValue
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(T.self, from: data)
                // print("Response: \(response)")
                completion?(response)
            } catch {
                print("Error decoding data: \(error)")
            }
            
            // print(String(data: data, encoding: .utf8)!)
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
}

/*
 CoinbaseService.shared.getApiResponse(api: CoinbaseApi.products,
                                       authRequired: false) { (products: [CurrencyPair]) in
     
     let USDPairs = products.filter { currencyPair in
         return String(currencyPair.id.suffix(3)) == "USD"
     }
     
     print("USD Curreny Pairs (Array): \(USDPairs)")
 }
 
 CoinbaseService.shared.getApiResponse(api: CoinbaseApi.profile,
                                       authRequired: true,
                                       requestPath: RequestPath.profile,
                                       httpMethod: HttpMethod.get) { (profiles: [Profile]) in
     
     guard let profile = profiles.first else { return } // 一個帳號怎樣都只有一個Profile, 但API會吐Array
     
     print("Profile: \(profile)")
 }

 CoinbaseService.shared.getApiResponse(api: CoinbaseApi.accounts,
                                       authRequired: true,
                                       requestPath: RequestPath.accounts,
                                       httpMethod: HttpMethod.get) { (accounts: [Account]) in
     let accountTotalBalance = accounts.reduce(0) { partialResult, account in
         if let balance = Double(account.balance) {
             // print("\(account.currency): \(balance)")
             return partialResult + balance
         } else {
             print("Invalid balance")
             return 0
         }
     }
     print("Total Account Balance: \(accountTotalBalance)")
 }
}
 
 */
