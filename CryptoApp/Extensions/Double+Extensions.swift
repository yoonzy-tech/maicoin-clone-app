//
//  Double+Extensions.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/29.
//

import Foundation

extension Double {
    func roundToDecimal(_ decimalPlaces: Int) -> Double {
        let multiplier = pow(10.0, Double(decimalPlaces))
        let roundedValue = (self * multiplier).rounded() / multiplier
        
        // Check if the rounded value is 0
        if roundedValue == 0.0 {
            let roundedToZero = (roundedValue * multiplier).rounded() / multiplier
            return roundedToZero
        }
        return roundedValue
    }
    
    func formatMarketData() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        
        if self < 1 {
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 4
        } else {
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = 2
        }
        
        let formattedRate = numberFormatter.string(from: NSNumber(value: self)) ?? ""
        
        return formattedRate.isEmpty ? "0.00" : formattedRate
    }
}
