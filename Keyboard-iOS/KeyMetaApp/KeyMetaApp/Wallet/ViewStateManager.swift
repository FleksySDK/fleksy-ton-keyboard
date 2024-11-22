import Foundation

class ViewStateManager: ObservableObject {
    @Published var showToast: Bool = false
    let walletState = WalletState()
}
