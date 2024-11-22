//  WalletView.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI

struct DataValidation: Codable {
    let sessionId: String
    let text: String
}

func doDataValidation(viewStateManager: ViewStateManager) {
    if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.thingthing.KeyMeta") {
        let resourcesURL = sharedContainerURL.appendingPathComponent("Resources")
        let fileURL = resourcesURL.appendingPathComponent("logger_typing_validate.log")
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(DataValidation.self, from: data)
            
            try FileManager.default.removeItem(at: fileURL)
            
            let messageProcessor = DefaultTonLogicMessageProcessor(viewStateManager: viewStateManager)
            let message = WebMessageModel(
                type: "OnDataValidation",
                success: true,
                message: decodedData.sessionId
            )
            messageProcessor.processMessage(message)
            
            viewStateManager.showToast = true
        } catch {
            print("Failed to process logger_typing_validate.log: \(error)")
        }
    }
}

struct WalletInfoView: View {
    @ObservedObject var walletState: WalletState
    @EnvironmentObject var viewStateManager: ViewStateManager
    
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
                            VStack {
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
                                
                                Button("Collect") {
                                    doDataValidation(viewStateManager: viewStateManager)                                    
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top, 8)
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
                            VStack {
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
                                
                                Button("Collect") {
                                    doDataValidation(viewStateManager: viewStateManager)
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top, 8)
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
            .overlay(
                Group {
                    if viewStateManager.showToast {
                        ToastView(message: "Data validated successfully")
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    viewStateManager.showToast = false
                                }
                            }
                    }
                }
            )
        }
    }
}

struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding()
            .background(Color(.systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(10)
            .shadow(radius: 5)
            .transition(.move(edge: .top))
            .animation(.easeInOut, value: true)
            .padding(.top, 20)
    }
}

struct WalletView: View {
    @StateObject private var webViewStore = WebViewStore()
    @EnvironmentObject var viewStateManager: ViewStateManager
    @State private var validationData: DataValidation?
    
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

