//
//  String+Extensions.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/29.
//

import Foundation

extension String {
    func formatAsAccountNumber() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        guard let number = numberFormatter.number(from: self),
              let formattedString = numberFormatter.string(from: number) else {
            return self
        }
        
        return formattedString
    }
}

