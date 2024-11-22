//  WalletView.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI

struct WalletView: View {
        
    var body: some View {
        VStack{
            
            Text("Connect your Wallet")
                .padding()
            WebView(url: URL(string:"https://www.google.com")!)
                .frame(height:200)
                .border(Color.gray)
                .cornerRadius(5.0)
            Spacer()
            Button(action: {
                print("Button Example Tapped")
            }) {
                Text("This is a sample btn")
                     .foregroundColor(.white)
                     .padding()
                     .background(Color.blue)
                     .cornerRadius(8)
                }
        }
    }
}
