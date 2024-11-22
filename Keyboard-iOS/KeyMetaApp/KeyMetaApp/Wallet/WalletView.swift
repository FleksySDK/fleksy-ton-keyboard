//  WalletView.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI

struct WalletInfoView: View {
    @ObservedObject var walletState: WalletState
    
    var body: some View {
        VStack {
            if walletState.isConnected {
                if let metadata = walletState.jettonMetadata {
                    AsyncImage(url: URL(string: metadata.image)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    } placeholder: {
                        ProgressView()
                    }

                    Text("\(metadata.symbol) Balance: \(walletState.jettonBalance)")
                }
            }
        }
    }
}

struct WalletView: View {
    @StateObject private var webViewStore = WebViewStore()
    @EnvironmentObject var viewStateManager: ViewStateManager

    // private let walletConnectUrl = URL(string: "https://d4rh1z6vnsnbq.cloudfront.net")
    private let walletConnectUrl = URL(string: "http://192.168.1.67:3000")!

    var body: some View {
        VStack {
            WebView(webViewStore: webViewStore)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            WalletInfoView(walletState: viewStateManager.walletState)
        }
    }
}

class WebViewStore: ObservableObject {
    @Published var webView: WebView?
    
    func sendMessage(type:String, payload:String) {
        webView?.sendMessageToWeb(type:type, payload:payload)
    }
}

#Preview {
    WalletView()
}

