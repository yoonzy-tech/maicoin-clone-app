//
//  MarketChartViewModel.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/1.
//

enum Time: Int {
    case day, week
    case month, threeMonth, year, all
}

struct Candle {
    var timestamp: Double = 0
    var averagePrice: Double = 0
}

import Foundation

class MarketChartViewModel {
    // CoinCode, Pair ID: ("BTC", "BTC-USD")
    var productID: ObservableObject<String> = ObservableObject("")
    
    var productPack: ObservableObject<ProductPack> = ObservableObject(ProductPack())
    
    var historyDataSource: ObservableObject<[Order]?> = ObservableObject(nil)
    
    var candles: ObservableObject<[[Double]]> = ObservableObject([])
    
    var realtimeBuyPrice: ObservableObject<Double> = ObservableObject(0)
    
    var realtimeSellPrice: ObservableObject<Double> = ObservableObject(0)
    
    func getProductOrderHistoryNEW(completion: @escaping () -> Void, errorHandle: @escaping (Error) -> Void) {
        let productId = productPack.value.productId
        CoinbaseService.shared.getOrderHistory(productId: productId) { [weak self] orders in
            let sortedOrders = orders.sorted { $0.doneAt ?? "" > $1.doneAt ?? "" }
            self?.historyDataSource.value = sortedOrders
        } errorHandle: { error in
            errorHandle(error)
        }
    }
    
    func getTimeCandles(time: Time, completion: @escaping ([Candle]) -> Void) {
        
        // get the date today
        let calendar = Calendar.current // use the current calander
        let endDate = Date() // get current date
        var startDate: Date
        var granularity: String
        
        switch time {
        case .day:
            granularity = "3600"
            startDate = calendar.date(byAdding: .day, value: -1, to: endDate) ?? Date()
        case .week:
            granularity = "21600"
            startDate = calendar.date(byAdding: .day, value: -7, to: endDate) ?? Date()
        case .month:
            granularity = "86400"
            startDate = calendar.date(byAdding: .month, value: -1, to: endDate) ?? Date()
        case .threeMonth:
            granularity = "86400"
            startDate = calendar.date(byAdding: .month, value: -3, to: endDate) ?? Date()
        case .year:
            return
        case .all:
            return
        }
        
        let productId = productPack.value.productId
        let endTime = "\(Int(endDate.timeIntervalSince1970))"
        let startTime = "\(Int(startDate.timeIntervalSince1970))"
        CoinbaseService.shared.getProductCandles(productId: productId, granularity: granularity,
                                                 startTime: startTime, endTime: endTime) { candlesArr in

            var extractedCandles: [Candle] = candlesArr.compactMap { candle in
                // Calculate Average Price
                let low = candle[1]
                let high = candle[2]
                let avgPrice = (low + high) / 2
                return Candle(timestamp: candle[0], averagePrice: avgPrice)
            }
            extractedCandles.reverse()
            
            // print("Extracted Candles: \(extractedCandles)")
            completion(extractedCandles)
        }
    }
    
    func getAllCandles(completion: @escaping ([Candle]) -> Void) {
        let group = DispatchGroup()
        group.enter()
        
        let calendar = Calendar.current
        var endDate = Date()

        let productId = productPack.value.productId
        let granularity = "86400"
        
        let semaphore = DispatchSemaphore(value: 0)
        var candlesResponse = [[Double]]()
        var index: Double = 0
        var extractedCandles = [Candle]()
        
        repeat {
            let startDate = calendar.date(byAdding: .day, value: -300, to: endDate) ?? Date()
            let startTime = "\(Int(startDate.timeIntervalSince1970))"
            var endTime = "\(Int(endDate.timeIntervalSince1970))"
            // print("❗️Start: \(startTime)")
            // print("❗️End: \(endTime)")
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1 * index) {
                
                CoinbaseService.shared.getProductCandles(productId: productId, granularity: granularity,
                                                         startTime: startTime, endTime: endTime) { candlesArr in
                    
                    candlesArr.forEach { candle in
                        // Calculate Average Price
                        let low = candle[1]
                        let high = candle[2]
                        let avgPrice = (low + high) / 2
                        let element = Candle(timestamp: candle[0], averagePrice: avgPrice)
                        extractedCandles.insert(element, at: 0)
                    }
                    
                    candlesResponse = candlesArr
                    endDate = startDate
                    index += 1
                    semaphore.signal()
                }
            }
            semaphore.wait()
        } while (candlesResponse.count != 0)
        
        group.leave()
        group.notify(queue: .main) {
            extractedCandles.sort { $0.timestamp < $1.timestamp }
            completion(extractedCandles)
        }
    }
    
    func getYearCandles(completion: @escaping ([Candle]) -> Void) {
        let group = DispatchGroup()
        let calendar = Calendar.current
        let endDate = Date()
        let threeHundredDaysAgo = calendar.date(byAdding: .day, value: -300, to: endDate) ?? Date()
        let aYearAgo = calendar.date(byAdding: .year, value: -1, to: endDate) ?? Date()
        
        let productId = productPack.value.productId
        let granularity = "86400"
        let endTime = "\(Int(endDate.timeIntervalSince1970))"
        let threeHundredDaysAgoTime = "\(Int(threeHundredDaysAgo.timeIntervalSince1970))"
        let aYearAgoTime = "\(Int(aYearAgo.timeIntervalSince1970))"
        var extractedCandles = [Candle]()
        
        group.enter()
        CoinbaseService.shared.getProductCandles(productId: productId, granularity: granularity,
                                                 startTime: threeHundredDaysAgoTime, endTime: endTime) { candlesArr in
            candlesArr.forEach { candle in
                // Calculate Average Price
                let low = candle[1]
                let high = candle[2]
                let avgPrice = (low + high) / 2
                let element = Candle(timestamp: candle[0], averagePrice: avgPrice)
                extractedCandles.insert(element, at: 0)
            }
            group.leave()
        }
        
        group.enter()
        CoinbaseService.shared.getProductCandles(productId: productId, granularity: granularity,
                                                 startTime: aYearAgoTime, endTime: threeHundredDaysAgoTime) { candlesArr in
            
            candlesArr.forEach { candle in
                // Calculate Average Price
                let low = candle[1]
                let high = candle[2]
                let avgPrice = (low + high) / 2
                let element = Candle(timestamp: candle[0], averagePrice: avgPrice)
                extractedCandles.insert(element, at: 0)
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            extractedCandles.sort { $0.timestamp < $1.timestamp }
            completion(extractedCandles)
        }
    }
}
