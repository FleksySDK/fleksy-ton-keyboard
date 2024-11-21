//  AboutAppView.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI
import StoreKit

struct AboutAppView: View {
    
    private static let privacyPolicyURL = URL(string: "https://www.fleksy.com/privacy/")!
    private static let termsOfUseURL = URL(string: "https://www.fleksy.com/medical-keyboard-terms/")!
    
    @EnvironmentObject private var store: SubscriptionStore
    @State private var isShowingManageSubscriptions: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("Privacy policy") {
                        WebView(url: Self.privacyPolicyURL)
                    }
                    NavigationLink("Terms of use") {
                        WebView(url: Self.termsOfUseURL)
                    }
                }
                
                if store.subscriptionGroupStatus.isSubscribed {
                    Section {
                        Button("Manage subscription") {
                            isShowingManageSubscriptions = true
                        }
                    }
                }
            }
            .navigationTitle("About")
        }
        .navigationViewStyle(.stack)
        .manageSubscriptionsSheet(isPresented: $isShowingManageSubscriptions)
    }
}
