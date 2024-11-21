//  SubscriptionView:.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    
    @EnvironmentObject private var store: SubscriptionStore
    
    @State private var selectedProduct: Product?
    
    @Binding var isPresented: Bool
            
    @State private var alertData: AlertData?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                ScrollView {
                    Group {
                        HStack {
                            Text("Unlock the full\npotential")
                                .font(.customTitle)
                                .bold()
                                .multilineTextAlignment(.leading)
                                .padding(.trailing, 100)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize()
                            
                            Spacer()
                        }
                        
                        Spacer()
                            .frame(minHeight: 20)
                        
                        Group {
                            Text("Features".localizedUppercase)
                                .font(.customFootnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                                .frame(height: 20)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.fixed(20)), GridItem(.flexible())], alignment: .leading, spacing: 14) {
                                ForEach(featuresTexts, id: \.self) { text in
                                    Text(text)
                                        .font(.customBody)
                                        .fixedSize()
                                    Image(systemName: "checkmark.circle.fill")
                                        .padding(.leading, 50)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    
                                }
                            }
                        }
                        
                        Spacer()
                            .frame(minHeight: 20)
                        
                        Group {
                            Divider()
                            ForEach(store.subscriptions) { product in
                                Button {
                                    selectedProduct = product
                                } label: {
                                    SubscriptionOptionRow(option: product, selectedOption: $selectedProduct)
                                }
                                .frame(maxWidth: .infinity)
                                Divider()
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(minHeight: 20)
                        
                        Group {
                            Button {
                                purchaseAction()
                            } label: {
                                ZStack(alignment: .center) {
                                    Text(buttonTitle)
                                        .font(.customTitle2)
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .foregroundColor(.white)
                                        .opacity(store.status == .makingPurchase ? 0 : 1)
                                    if store.status == .makingPurchase {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                    }
                                }
                            }
                            .background(Color.accentColor)
                            .cornerRadius(10)
                            .padding(.vertical, 10)
                            .disabled(selectedProduct == nil)
                            
                            Text("Cancel anytime".localizedUppercase)
                                .font(.customFootnote)
                                .foregroundColor(.secondary)
                            Button {
                                restorePurchasesAction()
                            } label: {
                                ZStack(alignment: .center) {
                                    Text("Restore purchases")
                                        .font(.customBody)
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .foregroundColor(.accentColor)
                                        .opacity(store.status == .restoringPurchases ? 0 : 1)
                                    if store.status == .restoringPurchases {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 40)
                    .padding(.bottom)
                    .frame(minHeight: geometry.size.height)
                }
                
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                        .frame(width: 40, height: 40)
                        .fixedSize()
                        .padding(10)
                }
            }
            .disabled(store.status.disableUI)
        }
        .onAppear {
            selectedProduct = store.subscriptions.first
        }
        .alert(alertTitle, isPresented: alertPresented) {
            Button("OK", role: .cancel, action: {
                alertData?.completion()
            })
        } message: {
            Text(alertMessage)
        }
    }
    
    private var alertPresented: Binding<Bool> {
        Binding<Bool> {
            return alertData != nil
        } set: { newValue in
            if !newValue {
                alertData = nil
            }
        }
    }
    
    private var alertTitle: LocalizedStringKey {
        alertData?.title ?? ""
    }
    
    private var alertMessage: LocalizedStringKey {
        alertData?.message ?? ""
    }
    
    private let featuresTexts: [String] = [
        NSLocalizedString("100,000 medical terms", comment: ""),
        NSLocalizedString("AutoCorrection", comment: ""),
        NSLocalizedString("Swipe Typing", comment: ""),
        NSLocalizedString("Custom Theme", comment: "")
    ]
    
    private var buttonTitle: String {
        guard let selectedProduct else {
            return NSLocalizedString("Choose a plan", comment: "")
        }
        return NSLocalizedString(String(format: "Continue with %@ plan", selectedProduct.title), comment: "")
    }
    
    private func restorePurchasesAction() {
        Task {
            let restoreResult = await store.restorePurchases()
            switch restoreResult {
            case .nothingToRestore:
                alertData = AlertData(title: nil, 
                                      message: "There are no purchases to restore",
                                      completion: {})
            case .error(let error):
                if case StoreKitError.userCancelled = error {
                    break // do nothing
                } else {
                    alertData = AlertData(title: "Error",
                                          message: "Purchases could not be restored. Try again later",
                                          completion: { })
                }
            case .purchaseRestored:
                alertData = AlertData(title: nil,
                                      message: "Purchase restored successfully",
                                      completion: { isPresented = false })
            }
        }
    }
    
    private func purchaseAction() {
        guard let selectedProduct else {
            return
        }
        Task {
            await purchaseProduct(selectedProduct)
        }
    }
    
    private func purchaseProduct(_ product: Product) async {
        do {
            if let _ = try await store.purchase(product) {
                isPresented = false
            }
        } catch StoreError.failedVerification {
            alertData = AlertData(title: "Error",
                                  message: "Your purchase could not be verified by the App Store.",
                                  completion: {})
        } catch {
            alertData = AlertData(title: "Error",
                                  message: "Failed to process your purchase. Please, try again later.",
                                  completion: {})
            print("Failed purchase for \(product.id): \(error)")
        }
    }
}

#Preview {
    SubscriptionView(isPresented: Binding<Bool>.constant(true))
        .environmentObject(SubscriptionStore())
}


struct AlertData {
    let title: LocalizedStringKey?
    let message: LocalizedStringKey
    let completion: () -> ()
}
