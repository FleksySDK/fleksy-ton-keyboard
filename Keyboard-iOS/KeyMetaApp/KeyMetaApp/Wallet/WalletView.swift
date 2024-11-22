//  WalletView.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI

struct WalletInfoView: View {
    @ObservedObject var walletState: WalletState
    
    private func formatBalance(_ balance: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: balance)) ?? "0.00"
    }
    
    var body: some View {
        if walletState.isConnected, let metadata = walletState.jettonMetadata {
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                
                Group {
                    if isLandscape {
                        // Horizontal Layout
                        HStack(spacing: 16) {
                            // Token Image
                            AsyncImage(url: URL(string: metadata.image)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 80, height: 80)
                            }
                            
                            // Balance Info
                            VStack(spacing: 8) {
                                Text(metadata.symbol)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text(formatBalance(walletState.jettonBalance))
                                    .font(.title2)
                                    .bold()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                            )
                        }
                    } else {
                        // Vertical Layout
                        VStack(spacing: 16) {
                            // Token Image
                            AsyncImage(url: URL(string: metadata.image)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 80, height: 80)
                            }
                            
                            // Balance Info
                            VStack(spacing: 8) {
                                Text(metadata.symbol)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text(formatBalance(walletState.jettonBalance))
                                    .font(.title2)
                                    .bold()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                            )
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct WalletView: View {
    @StateObject private var webViewStore = WebViewStore()
    @EnvironmentObject var viewStateManager: ViewStateManager
    
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

