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
        
        if roundedValue == 0.0 {
            let roundedToZero = (roundedValue * multiplier).rounded() / multiplier
            return roundedToZero
        }
        return roundedValue
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
