//
//  Double+Extensions.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/29.
//

import Foundation

extension Double {
    func convertToTWD() -> Double {
        var convertedAmount: Double = 0
        let semaphore = DispatchSemaphore(value: 0)
        CoinbaseService.shared.getExchangeRate { twdRate in
            convertedAmount = self * twdRate
            semaphore.signal()
        }
        semaphore.wait()
        
        return convertedAmount
    }
    
    func roundedDouble(toDecimalPlaces: Int) -> Double {
        let multiplier = pow(10.0, Double(toDecimalPlaces))
        let roundedValue = (self * multiplier).rounded() / multiplier
        return roundedValue
    }
    
    func formattedAccountingString(decimalPlaces: Int, accountFormat: Bool) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = accountFormat ? .decimal : .none
        numberFormatter.groupingSeparator = ","
        numberFormatter.decimalSeparator = "."
        numberFormatter.minimumFractionDigits = decimalPlaces
        numberFormatter.maximumFractionDigits = decimalPlaces
        
        let formattedNumber = numberFormatter.string(from: NSNumber(value: self))
        
        if let result = formattedNumber, self > 0 {
            return result
        } else {
            return "0"
        }
    }
    
    func formatMarketDataString() -> String {
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
