//
//  Double+Extensions.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/29.
//

import Foundation

extension Double {
    // New Keep
//    func rounded(toDecimalPlaces decimalPlaces: Int) -> Double {
//        let multiplier = pow(10.0, Double(decimalPlaces))
//        return (self * multiplier).rounded() / multiplier
//    }
    
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
    
    func roundedDouble(toDecimalPlaces: Int) -> Double {
        let multiplier = pow(10.0, Double(toDecimalPlaces))
        let roundedValue = (self * multiplier).rounded() / multiplier
        return roundedValue
    }
        
    func roundedString(toDecimalPlaces: Int) -> String {
        let multiplier = pow(10.0, Double(toDecimalPlaces))
        let roundedValue = (self * multiplier).rounded() / multiplier
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = toDecimalPlaces
        let formattedNumber = numberFormatter.string(from: NSNumber(value: roundedValue))
        
        if let result = formattedNumber {
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
    
    func formatMarketDataDouble() -> Double {
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
        
        let formattedNumberString = numberFormatter.string(from: NSNumber(value: self)) ?? ""
        
        guard let formattedNumber = numberFormatter.number(from: formattedNumberString) else {
            return 0.0 // Return default value if formatting fails
        }
        
        return formattedNumber.doubleValue
    }
    
    func convertToTWD() -> Double {
        var convertedAmount: Double = 0
        
        let semaphore = DispatchSemaphore(value: 0)
        
        CoinbaseService.shared.fetchCurrencyRate { fetchedRate in
            convertedAmount = self * fetchedRate
            semaphore.signal()
        }
        semaphore.wait()
        
        return convertedAmount
    }
}
