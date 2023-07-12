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
    
    var subscribeProductId: String!
    
    var completion: ((TickerMessage) -> Void)?
    
    func connect() {
        var request = URLRequest(url: URL(string: "wss://ws-feed-public.sandbox.exchange.coinbase.com")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func send(string: String) {
        socket.write(string: string)
    }
    
    func disconnect() {
        socket.disconnect()
        socket.delegate = nil
    }
    
    func subscribe(productId: String) {
        let subscriptionMessage = """
            {
                "type": "subscribe",
                "product_ids": [
                    "\(productId)"
                ],
                "channels": ["ticker_batch"]
            }
        """
        socket.write(string: subscriptionMessage)
    }
    
    func unsubscribe(productId: String) {
        // Unsubscribe from the ticker batch channel
        let unsubscribeMessage = """
            {
                "type": "unsubscribe",
                "product_ids": [
                    "\(productId)"
                ],
                "channels": ["ticker_batch"]
            }
        """
        socket.write(string: unsubscribeMessage)
    }
}

 // MARK: Websocket Delegate

extension WebsocketService: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocket) {
        switch event {
        case .connected(let headers):
            // subscribe channel
            self.subscribe(productId: subscribeProductId)
            
            print("websocket is connected: \(headers)")

        case .disconnected(let reason, let code):

            print("WebSocket is disconnected: \(reason) with code: \(code)")

        case .text(let string):
            print("Received text: \(string)")
            // Process received data
            if let data = string.data(using: .utf8) {
                do {
                    let decoder = JSONDecoder()
                    let tickerMessage = try decoder.decode(TickerMessage.self, from: data)
                    if tickerMessage.type == "ticker" {
                        self.completion?(tickerMessage)
                    }
                } catch {
                    print("Failed to decode ticker message: \(error)")
                }
            }
            
        case .binary(let data):
            print("Received data: \(data.count)")
            // Process received data
        case .ping:
            break
        case .pong:
            break
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            break
        case .error(let error):
            handleError(error)
        }
    }

    func handleError(_ error: Error?) {
        if let error = error as? WSError {
            print("Websocket encountered an error: \(error.message)")
        } else if let error = error {
            print("Websocket encountered an error: \(error.localizedDescription)")
        } else {
            print("Websocket encountered an error")
        }
    }
}
