//  ActionKeyboardAppView.swift
//  Keyboard
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI
import FleksyAppsCore

struct ActionKeyboardAppView: View {
    
    let buttonTitle: LocalizedStringKey
    var theme: AppTheme
    let onButtonAction: () -> ()
    let onCloseAction: () -> ()
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Button(buttonTitle, action: onButtonAction)
                .foregroundColor(Color(uiColor: theme.foreground))
                .padding(.vertical, 4)
                .padding(.horizontal)
                .background(Color(uiColor: theme.keyBackground))
                .cornerRadius(10)
                .fixedSize()
                .padding(8)
            
            Spacer()
            
            Button {
                onCloseAction()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(width: 40, height: 40)
                    .fixedSize()
            }
        }
    }
}
