//  SubscriptionItemCell.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI
import StoreKit

struct SubscriptionItemCell: View {
    @EnvironmentObject var store: SubscriptionStore
    @State private var isPurchased: Bool = false
    @State private var errorTitle: String = ""
    @State private var isShowingError: Bool = false
    
    let product: Product
    
    init(product: Product) {
        self.product = product
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                productDetail
                    .frame(maxWidth: .infinity)
                Spacer()
                buyButton
                    .buttonStyle(BuyButtonStyle(isPurchased: isPurchased))
                    .disabled(isPurchased)
            }
        }
    }
    
    private var productDetail: some View {
        VStack(alignment: .leading) {
            Text(product.displayName)
                .bold()
            Text(product.description)
        }
    }
    
    @ViewBuilder
    private var buyButton: some View {
        Button {
            Task {
                await buy()
            }
        } label: {
            if isPurchased {
                Text(Image(systemName: "checkmark"))
                    .bold()
                    .foregroundColor(.white)
            } else {
                if let subscription = product.subscription {
                    subscribeButton(subscription)
                }
            }
        }
        .onAppear {
            updateIsPurchasedState()
        }
        .onReceive(store.objectWillChange) {
            updateIsPurchasedState()
        }
    }
    
    private func subscribeButton(_ subscription: Product.SubscriptionInfo) -> some View {
        let unit: String
        let periodValue = subscription.subscriptionPeriod.value
        switch subscription.subscriptionPeriod.unit {
        case .day:
            unit = "\(periodValue) days"
        case .week:
            unit = "\(periodValue) weeks"
        case .month:
            unit = "\(periodValue) months"
        case .year:
            unit = "\(periodValue) years"
        @unknown default:
            unit = "period"
        }
        
        return VStack {
            Text(product.displayPrice)
                .foregroundColor(.white)
                .bold()
                .padding(.top, -4)
            Text(unit)
                .foregroundColor(.white)
                .font(.footnote)
                .padding(.bottom, -4)
        }
    }
    
    private func buy() async {
        do {
            if let _ = try await store.purchase(product) {
                withAnimation {
                    updateIsPurchasedState()
                }
            }
        } catch StoreError.failedVerification {
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            errorTitle = "Failed to process your purchase. Please, try again later."
            isShowingError = true
            print("Failed purchase for \(product.id): \(error)")
        }
    }
    
    private func updateIsPurchasedState() {
        isPurchased = store.isPurchased(product)
    }
}
