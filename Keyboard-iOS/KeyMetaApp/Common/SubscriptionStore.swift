//  SubscriptionStore.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import StoreKit

typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
    case failedVerification
}

class SubscriptionStore: ObservableObject {
    
    private struct PurchaseProductMetadata {
        let product: Product
        let expiration: Date?
    }
    
    @MainActor @Published private(set) var subscriptions: [Product] = []
    @MainActor private var purchasedSubscriptions: [PurchaseProductMetadata] = []
    @MainActor @Published private(set) var subscriptionGroupStatus: RenewalState?
    
    enum Status {
        case loadingInitialData
        case makingPurchase
        case restoringPurchases
        case idle
        
        var disableUI: Bool {
            switch self {
            case .makingPurchase, .restoringPurchases:
                true
            case .idle, .loadingInitialData:
                false
            }
        }
    }
    @MainActor @Published private(set) var status: Status = .idle
    
    enum RestorePurchaseResult {
        case nothingToRestore
        case error(Error)
        case purchaseRestored
    }
        
    var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        // Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions()
        
        Task {
            await setStatus(.loadingInitialData)
                        
            // During store initialization, request products from the App Store.
            await requestProducts()

            // Deliver products that the customer purchases.
            await updateCustomerProductStatus()
            
            await setStatus(.idle)
        }
    }
    
    // MARK: - Interface
    
    func restorePurchases() async -> RestorePurchaseResult {
        await setStatus(.restoringPurchases)
        
        do {
            try await AppStore.sync()
        } catch {
            await setStatus(.idle)
            return .error(error)
        }
        
        await setStatus(.idle)
        if await subscriptionGroupStatus.isSubscribed {
            return .purchaseRestored
        } else {
            return .nothingToRestore
        }
    }
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        await setStatus(.makingPurchase)
        // Begin purchasing the `Product` the user selects.
        let result = try await product.purchase()
        
        let transaction: StoreKit.Transaction?

        switch result {
        case .success(let verification):
            // Check whether the transaction is verified. If it isn't,
            // this function rethrows the verification error.
            transaction = try checkVerified(verification)

            // The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()

            // Always finish a transaction.
            await transaction?.finish()
        case .userCancelled, .pending:
            transaction = nil
        default:
            transaction = nil
        }
        
        await setStatus(.idle)
        return transaction
    }
    
    @MainActor func isPurchased(_ product: Product) -> Bool {
        // Determine whether the user already purchased a given product.
        return purchasedSubscriptions.contains(where: { $0.product == product })
    }
    
    @MainActor func expirationDateForPurchasedProduct(_ product: Product) -> Date? {
        let metadata = purchasedSubscriptions.first(where: { $0.product == product })
        return metadata?.expiration
    }
    
    // MARK: - Private methods
    
    @MainActor private func setStatus(_ status: Status) {
        self.status = status
    }
    
    @MainActor private func requestProducts() async {
        do {
            // Request products from the App Store using the identifiers that the MediKeyStoreMetadata.plist file defines.
            // **IMPORTANT**: If new subscriptions options are to be added, update MediKeyStoreMetadata.plist accordingly
            let storeProducts = try await Product.products(for: Self.storeProductIds)

            var newSubscriptions: [Product] = []

            // Filter the products into categories based on their type.
            for product in storeProducts {
                switch product.type {
                case .autoRenewable:
                    newSubscriptions.append(product)
                default:
                    //Ignore this product.
                    print("Unknown product")
                }
            }

            subscriptions = sortByHigherPrice(newSubscriptions)
        } catch {
            print("Failed product request from the App Store server: \(error)")
        }
    }
    
    private static var storeProductIds: [String] {
        return SubscriptionOptionMetadata.all.map { $0.productID }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    // Deliver products to the user.
                    await self.updateCustomerProductStatus()

                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
    @MainActor
    private func updateCustomerProductStatus() async {
        var purchasedSubscriptions: [PurchaseProductMetadata] = []
        
        // Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                // Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try checkVerified(result)
                // Check the `productType` of the transaction and get the corresponding product from the store.
                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                        let metadata = PurchaseProductMetadata(product: subscription, expiration: transaction.expirationDate)
                        purchasedSubscriptions.append(metadata)
                    }
                default:
                    break
                }
            } catch {
                print(error)
            }
        }
        
        // Update the store information with auto-renewable subscription products.
        self.purchasedSubscriptions = purchasedSubscriptions

        // Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
        // is new (never subscribed), active, or inactive (expired subscription). This app has only one subscription
        // group, so products in the subscriptions array all belong to the same group. The statuses that
        // `product.subscription.status` returns apply to the entire subscription group.
        let allStatuses = (try? await subscriptions.first?.subscription?.status.map { $0.state }) ?? []
        if allStatuses.contains(.subscribed) {
            subscriptionGroupStatus = .subscribed
        } else if allStatuses.contains(.inGracePeriod) {
            subscriptionGroupStatus = .inGracePeriod
        } else if allStatuses.contains(.inBillingRetryPeriod) {
            subscriptionGroupStatus = .inBillingRetryPeriod
        } else {
            subscriptionGroupStatus = allStatuses.first
        }
        Preferences.latestSubscriptionStatus = subscriptionGroupStatus?.rawValue
    }
    
    private func sortByHigherPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price > $1.price })
    }
}

extension Optional<RenewalState> {
    
    var isSubscribed: Bool {
        switch self {
        case .subscribed?, .inGracePeriod?:
            return true
        default:
            return false
        }
    }
}
