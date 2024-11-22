import SwiftUI

class DefaultTonLogicMessageProcessor: TonLogicMessageProcessor {
    private let viewStateManager: ViewStateManager
    private let baseURL = "https://egret-shining-whippet.ngrok-free.app";
    
    required init(viewStateManager: ViewStateManager) {
        self.viewStateManager = viewStateManager
    }
    
    func processMessage(_ message: WebMessageModel) {
        switch message.type {
        case "onConnectWallet":
            if message.success {
                DispatchQueue.main.async {
                    self.viewStateManager.walletState.connect(address: message.message)
                    
                    Task {
                        do {
                            let result = try await self.fetchJettonInfo(walletAddress: message.message)
                            
                            if let success = result["success"] as? Bool,
                               success,
                               let data = result["data"] as? [String: Any],
                               let balance = data["balance"] as? Double,
                               let metadata = data["metadata"] as? [String: Any],
                               let jettonWalletAddress = data["jettonWalletAddress"] as? String {
                                
                                DispatchQueue.main.async {
                                    self.viewStateManager.walletState.updateJettonInfo(
                                        balance: balance,
                                        metadata: metadata,
                                        jettonWalletAddress: jettonWalletAddress
                                    )
                                }
                            }
                        } catch {
                            print("Error fetching jetton info: \(error)")
                        }
                    }
                    
                    /*
                    Task {
                        do {
                            let result = try await self.sendJettons(
                                receiverAddress: message.message,
                                payload: "{}"
                            )
                            print("Send jettons result: \(result)")
                        } catch {
                            print("Error sending jettons: \(error)")
                        }
                    }
                     */
                }
            }
        case "onDisconnectWallet":
            DispatchQueue.main.async {
                self.viewStateManager.walletState.disconnect()
            }
        default:
            print("Unknown message type: \(message.type)")
        }
    }

    func fetchJettonInfo(walletAddress: String) async throws -> [String: Any] {        
        let path = "/api/jettons-info/\(walletAddress)"
        
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        guard let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }
        
        return jsonResult
    }

    func sendJettons(receiverAddress: String, payload: String) async throws -> [String: Any] {
        let path = "/api/send-jettons"
        
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        
        // Create the request body
        let body: [String: Any] = [
            "receiverAddress": receiverAddress,
            "payload": payload
        ]
        
        // Convert body to JSON data
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        // Create and configure the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Make the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        guard let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }
        
        return jsonResult
    }
} 
