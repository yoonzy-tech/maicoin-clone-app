//
//  CoinbaseService+Helpers.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/30.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import CryptoKit
import JGProgressHUD

extension CoinbaseService {
    // MARK: With Semaphore
    func getApiResponseSemaphore<T: Codable>(api: CoinbaseApi,
                                             authRequired: Bool,
                                             requestPath: String = "",
                                             httpMethod: HttpMethod = .GET,
                                             httpBody: String = "") -> T? {
        
        let semaphore = DispatchSemaphore(value: 0)
        var responseData: T?
        
        guard let url = URL(string: api.path) else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("🟩 URL: \(api.path)")
        print("🟩 Requests Path: \(requestPath)")
        print("🟩 Body: \(httpBody)")
        
        if authRequired {
            let authOutput = getAuthOutput(requestPath: requestPath, httpMethod: httpMethod.rawValue, httpBody: httpBody)
            print("Auth Output: \(authOutput)")
            request.addValue(apiKey, forHTTPHeaderField: "cb-access-key")
            request.addValue(passPhrase, forHTTPHeaderField: "cb-access-passphrase")
            request.addValue(authOutput.timestamp, forHTTPHeaderField: "cb-access-timestamp")
            request.addValue(authOutput.signature, forHTTPHeaderField: "cb-access-sign")
        }
        request.httpMethod = httpMethod.rawValue
        
        if httpMethod == .POST {
            let postData = httpBody.data(using: .utf8)
            request.httpBody = postData
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(T.self, from: data)
                responseData = response
                // print("📱 Response: \(responseData)")
            } catch {
                let response = String(data: data, encoding: String.Encoding.utf8) as Any
                print("API Error Response: \(response)")
                print("Error decoding data: \(error)")
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
        return responseData
    }
}
