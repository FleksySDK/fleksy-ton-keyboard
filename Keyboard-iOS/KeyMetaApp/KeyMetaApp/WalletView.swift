//  WalletView.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI
import StoreKit

struct WalletView: View {
        
    var body: some View {
        NavigationView {
            List {
                Section {
                    EmptyView()
                }
            }
            .navigationTitle("Wallet")
        }
        .navigationViewStyle(.stack)
    }
}
