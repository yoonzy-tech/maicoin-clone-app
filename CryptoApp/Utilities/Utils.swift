//
//  Utils.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/13.
//

import Foundation

class Utils {
    static func compactArray<T>(every num: Int, from array: [T]) -> [T] {
        var extractedElements: [T] = []
        
        for (index, element) in array.enumerated() {
            if (index + 1) % num == 0 {
                extractedElements.append(element)
            }
        }
        
        return extractedElements
    }
}
