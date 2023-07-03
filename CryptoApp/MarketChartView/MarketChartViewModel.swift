//
//  MarketChartViewModel.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/1.
//

enum Time {
    case day
    case week
    case month
    case threeMonth
    case year
    case all
}

import Foundation

class MarketChartViewModel {
    
    var productID: ObservableObject<String> = ObservableObject("")
    
    var historyDataSource: ObservableObject<[Order]?> = ObservableObject(nil)
    
    // CoinCode, Pair ID: ("BTC", "BTC-USD")
    var candles: ObservableObject<[[Double]]> = ObservableObject([])
    
    var realtimeBuyPrice: ObservableObject<Double> = ObservableObject(0)
    
    var realtimeSellPrice: ObservableObject<Double> = ObservableObject(0)
    
    func getProductOrderHistory() {
        CoinbaseService.shared.fetchProductOrders(productID: productID.value) { orders in
            let sortedOrders = orders.sorted { $0.doneAt > $1.doneAt }
            self.historyDataSource.value = sortedOrders
        }
    }
    
    func getProductCandles(time: Time,
                           startTime: Double? = nil,
                           endTime: Double? = nil) -> [Double] {
        
        var endAvgPriceArr: [Double] = []
        
        var granularity: Int
        
        // know which granularity to use
        switch time {
        case .day, .week:
            granularity = CBGranularity.hour.rawValue
        default:
            granularity = CBGranularity.twentyFourHours.rawValue
        }
        
        // call api
        var candles = CoinbaseService.shared.fetchProductCandlesTest(productID: productID.value,
                                                   granularity: granularity,
                                                   startTime: startTime,
                                                   endTime: endTime)
        if candles.count != 0 {
            
            // get the most recent candles timestamp
            var startTime: Double? = candles.first?.first
            var endTime: Double? = candles.last?.first
            var avgPriceArr: [Double] = []
            
            candles.forEach { candle in
                var low = candle[1]
                var high = candle[2]
                var avgPrice = Double((low + high) / 2)
                avgPriceArr.insert(avgPrice, at: 0)
            }
            
            endAvgPriceArr = avgPriceArr + endAvgPriceArr
            
            
            let newStartTime = minus300Days(timestamp: startTime ?? 0)
            let newEndTime = minus300Days(timestamp: endTime ?? 0)
            
            return getProductCandles(time: .all, startTime: newStartTime, endTime: newEndTime)
            
        } else {
            return endAvgPriceArr
        }
    }
    
}

extension MarketChartViewModel {
    func minus300Days(timestamp: Double) -> Double {
        let timestamp = timestamp // The original timestamp
        let daysToSubtract = 300

        // Convert the timestamp to a Date object
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))

        // Create a Calendar instance
        let calendar = Calendar.current

        // Subtract the desired number of days from the date
        if let modifiedDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: date) {
            // Convert the modified date back to a timestamp
            let modifiedTimestamp = Int(modifiedDate.timeIntervalSince1970)
            
            print("Original Timestamp: \(timestamp)")
            print("Modified Timestamp: \(modifiedTimestamp)")
            
            return Double(modifiedTimestamp)
        } else {
            print("Invalid Date")
            return Double()
        }
    }
}

/*
 
 // [ timestamp,
 // price low,
 // price high,
 // price open,
 // price close ]
 
 
 // get how many counts to get from the api response
 var numberOfDataToGet: Int?
 switch time {
 case .day:
     numberOfDataToGet = 24
 case .week:
     numberOfDataToGet = 24 * 7
 case .month:
     numberOfDataToGet = 30
 case .threeMonth:
     numberOfDataToGet = 30 * 3
 default:
     numberOfDataToGet = nil
 }
 
 
 
 
 */
