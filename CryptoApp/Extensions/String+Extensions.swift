//
//  String+Extensions.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/2.
//

import Foundation

extension String {
    func convertCoinbaseTimestamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: self)!
        let timeZoneOffset = TimeInterval(8 * 60 * 60) // 8 hours in seconds
        let utc8Date = date.addingTimeInterval(timeZoneOffset)

        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter2.timeZone = TimeZone(secondsFromGMT: 0) // Set the output time zone to UTC
        return dateFormatter2.string(from: utc8Date)
    }
    
    func convertToDouble(defaultValue: Double = 0.0) -> Double {
        let decimalSeparator = NumberFormatter().decimalSeparator ?? "."
        let nonDecimalCharacters = CharacterSet(charactersIn: "0123456789" + decimalSeparator).inverted
        let sanitizedString = self.components(separatedBy: nonDecimalCharacters).joined()
        
        if let convertedValue = Double(sanitizedString) {
            return convertedValue
        } else {
            return defaultValue
        }
    }
}
