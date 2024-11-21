//  OnboardingView.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI

/// View shown when the keyboard is either not installed or not granted full access.
struct OnboardingView: View {
    
    @EnvironmentObject private var installationState: KeyboardInstallationState
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack {
                    Text("Add KeyMeta")
                        .font(.customLargeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Spacer()
                    Spacer()
                    
                    LazyVGrid(columns: [GridItem(.fixed(44)), GridItem(.flexible())], alignment: .leading, spacing: 20, content: {
                        Image(.keyboardIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 42)
                            .padding(4)
                        Text("Tap **Keyboard**")
                            .padding()
                        Toggle("Turn on KeyMeta", isOn: .constant(true))
                            .labelsHidden()
                        Text("Turn On **KeyMeta**")
                            .padding()
                        Toggle("Turn on full access", isOn: .constant(true))
                            .labelsHidden()
                        Text("Turn On **Allow Full Access**")
                            .padding()
                    })
                    .padding(.leading, 50)
                    .padding(.trailing)

                    Spacer()
                    Spacer()
                    Spacer()

                    Button(action: {
                        openSettings()
                    }, label: {
                        Text("Add Keyboard")
                            .font(.customTitle3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                    })
                    .background(Color.accentColor)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 30)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
