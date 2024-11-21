//  HomeView.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI
import FleksyKeyboardSDK

/// Initial view of the app when the keyboard is installed and granted full access.
struct HomeView: View {
    
    @EnvironmentObject private var installationState: KeyboardInstallationState
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Text("KeyMeta")
                    .font(.customLargeTitle)
                    .fontWeight(.bold)
                    .fixedSize()
                    .padding(.top)
                
                Spacer()
                    .frame(minWidth: 10)
            }
            .padding(.horizontal, 32)
            
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Keyboard status:")
                        .font(.customFootnote)
                        .foregroundColor(.secondary)
                }
                HStack(alignment: .center, spacing: 16) {
                    Circle()
                        .frame(width: 14)
                        .foregroundColor(.accent)
                        .padding(.top, 4)
                    
                    Text("Installed")
                        .font(.customTitle3)
                        .foregroundColor(.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundColor(Color.customLightGray)
            }
            .padding(32)
            .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
