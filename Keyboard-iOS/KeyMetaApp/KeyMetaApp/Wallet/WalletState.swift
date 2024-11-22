import Foundation

// Add this struct above the WalletState class
struct JettonMetadata {
    let image: String
    let name: String
    let symbol: String
    let description: String
}

class WalletState: ObservableObject {
    @Published var isConnected = false
    @Published var address: String = ""
    @Published var jettonBalance: Int64 = 0
    @Published var jettonMetadata: JettonMetadata?
    @Published var jettonWalletAddress: String = ""
    
    func connect(address: String) {
        self.address = address
        self.isConnected = true
    }
    
    func disconnect() {
        self.address = ""
        self.isConnected = false
        self.jettonBalance = 0
        self.jettonWalletAddress = ""
        self.jettonMetadata = nil
    }

    func updateJettonInfo(balance: Int64, metadata: [String: Any], jettonWalletAddress: String) {
        self.jettonBalance = balance
        self.jettonWalletAddress = jettonWalletAddress
        
        // Parse metadata into our struct
        if let image = metadata["image"] as? String,
           let name = metadata["name"] as? String,
           let symbol = metadata["symbol"] as? String,
           let description = metadata["description"] as? String {
            
            self.jettonMetadata = JettonMetadata(
                image: image,
                name: name,
                symbol: symbol,
                description: description
            )
        }
    }
} 
