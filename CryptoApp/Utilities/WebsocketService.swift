//
//  WebsocketService.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/1.
//

import Foundation
import Starscream

class WebsocketService {
    
    static let shared = WebsocketService()
    
    private init() {}
    
    var socket: WebSocket!
    
    func connect() {
        var request = URLRequest(url: URL(string: "wss://ws-feed.exchange.coinbase.com")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        
        socket.connect()
    }
    
    func send(string: String) {
        socket.write(string: string)
    }
    
    func disconnect() {
        socket.disconnect()
        // socket.delegate = nil
    }
    
    func subscribe(productID: String) {
        let subscriptionMessage = """
            {
                "type": "subscribe",
                "product_ids": [
                    "\(productID)"
                ],
                "channels": ["ticker_batch"]
            }
        """
        socket.write(string: subscriptionMessage)
    }
    
    func unsubscribe(productID: String) {
        // Unsubscribe from the ticker batch channel
        let unsubscribeMessage = """
            {
                "type": "unsubscribe",
                "product_ids": [
                    "\(productID)"
                ],
                "channels": ["ticker_batch"]
            }
        """
        socket.write(string: unsubscribeMessage)
    }
}

// MARK: Websocket Delegate

//extension WebsocketService: WebSocketDelegate {
//    func didReceive(event: WebSocketEvent, client: WebSocket) {
//        switch event {
//        case .connected(let headers):
//
//            print("websocket is connected: \(headers)")
//
//        case .disconnected(let reason, let code):
//
//            print("WebSocket is disconnected: \(reason) with code: \(code)")
//
//        case .text(let string):
//            print("Received text: \(string)")
//            // Process received data
//        case .binary(let data):
//            print("Received data: \(data.count)")
//            // Process received data
//        case .ping:
//            break
//        case .pong:
//            break
//        case .viabilityChanged:
//            break
//        case .reconnectSuggested:
//            break
//        case .cancelled:
//            break
//        case .error(let error):
//            handleError(error)
//        }
//    }
//
//    func handleError(_ error: Error?) {
//        if let error = error as? WSError {
//            print("Websocket encountered an error: \(error.message)")
//        } else if let error = error {
//            print("Websocket encountered an error: \(error.localizedDescription)")
//        } else {
//            print("Websocket encountered an error")
//        }
//    }
//}
