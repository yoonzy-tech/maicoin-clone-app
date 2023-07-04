//
//  MarketChartViewModel.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/1.
//

enum Time: Int {
    case day, week = 3600
        // 24, 24 * 7
    case month, threeMonth, year, all = 86400
        // 30, 30 * 3, 30 * 12, N
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
    
    func getProductCandles(productID: String, time: Time, completion: @escaping ([Double]) -> Void) {
        
        var granularity: String
        
        switch time {
        case .day:
            granularity = "3600"
        case .week:
            granularity = "21600"
        case .month:
            granularity = "86400"
        case .threeMonth:
            granularity = "86400"
        case .year:
            granularity = "86400"
        case .all:
            granularity = "86400"
        }
        
        CoinbaseService.shared.fetchProductCandles(productID: productID,
                                                   granularity: granularity) { candles in
            
            var takeCount: Int
            
            switch time {
            case .day:
                takeCount = 24
            case .week:
                takeCount = 4 * 7
            case .month:
                takeCount = 30
            case .threeMonth:
                takeCount = 30 * 3
            default:
                takeCount = 0
            }
            
            if takeCount != 0 {
                var avgPriceArray: [Double] = []
                let filteredResponse = candles[0..<takeCount]
                filteredResponse.forEach { candle in
                    let low = candle[1]
                    let high = candle[2]
                    var avgPrice = (low + high) / 2
                    avgPrice = avgPrice.formatMarketDataDouble()
                    avgPriceArray.insert(avgPrice, at: 0)
                }
                completion(avgPriceArray)
            } else {
                // handle year, all
                
            }
        }
    }
    
    func getAllCandles(productID: String, completion: @escaping ([Double]) -> Void) {
        
        // get the date today
        let calendar = Calendar.current // use the current calander
        var endTime = Date() // get current date
        
        var avgPriceArray = [Double]()
        var candleResponse = [[Double]]()
        var index: Int = 0
        
        let semaphore = DispatchSemaphore(value: 0)
        
        repeat {
            // get a 300 days ago timestamp to fetch history: start, end
            let threeHundredDaysAgo = calendar.date(byAdding: .day, value: -300, to: endTime) ??  Date()
            
            CoinbaseService.shared.fetchProductCandles(productID: productID,
                                                       granularity: "86400",
                                                       startTime: "\(Int(threeHundredDaysAgo.timeIntervalSince1970))",
                                                       endTime: "\(Int(endTime.timeIntervalSince1970))") { candles in
    
                candles.forEach { candle in
                    let low = candle[1]
                    let high = candle[2]
                    var avgPrice = (low + high) / 2
                    avgPrice = avgPrice.formatMarketDataDouble()
                    avgPriceArray.insert(avgPrice, at: 0)
                }
                
                candleResponse = candles
                endTime = threeHundredDaysAgo
                index += 1
                semaphore.signal()
            }
            
            semaphore.wait()
            
        } while(candleResponse.count != 0) // condition to continue the loop
        
        completion(avgPriceArray)
    }
    
    func getYearCandles(productID: String, completion: @escaping ([Double]) -> Void) {
        let calendar = Calendar.current
        let todayDate = Date()
        let threeHundredDaysAgo = calendar.date(byAdding: .day, value: -300, to: todayDate) ??  Date()
        let yearAgo = calendar.date(byAdding: .year, value: -1, to: todayDate) ?? Date()
        var avgPriceArray: [Double] = []
        
        CoinbaseService.shared.fetchProductCandles(productID: productID,
                                                   granularity: "86400",
                                                   startTime: "\(Int(threeHundredDaysAgo.timeIntervalSince1970))",
                                                   endTime: "\(Int(todayDate.timeIntervalSince1970))") { candles in
            
            candles.forEach { candle in
                let low = candle[1]
                let high = candle[2]
                var avgPrice = (low + high) / 2
                avgPrice = avgPrice.formatMarketDataDouble()
                avgPriceArray.insert(avgPrice, at: 0)
            }
        }
        
        CoinbaseService.shared.fetchProductCandles(productID: productID,
                                                   granularity: "86400",
                                                   startTime: "\(Int(yearAgo.timeIntervalSince1970))",
                                                   endTime: "\(Int(threeHundredDaysAgo.timeIntervalSince1970))") { candles in
            
            candles.forEach { candle in
                let low = candle[1]
                let high = candle[2]
                var avgPrice = (low + high) / 2
                avgPrice = avgPrice.formatMarketDataDouble()
                avgPriceArray.insert(avgPrice, at: 0)
            }
        }
        
        completion(avgPriceArray)
    }
}
