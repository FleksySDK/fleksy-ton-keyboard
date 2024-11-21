//  SubscriptionOptionRow.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI
import StoreKit

struct SubscriptionOptionRow<Option: SubscriptionOption>: View {
    
    let option: Option
    @Binding var selectedOption: Option?
    
    var body: some View {
        HStack(spacing: 20) {
            Circle()
                .strokeBorder(strokeColor, lineWidth: strokeLineWidth)
                .background()
                .frame(width: circleSize, height: circleSize)
                .animation(.snappy, value: selectedOption)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(option.title)
                    .font(.customTitle3)
                    .bold()
                    .foregroundColor(.primary)
                Text(option.subtitle)
                    .font(.customTitle3)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private let circleSize: CGFloat = 25
    
    private var strokeColor: Color {
        selected ? .accentColor : .secondary
    }
    
    private var strokeLineWidth: CGFloat {
        selected ? 6 : 1
    }
    
    private var fillColor: Color {
        selected ? .primary : .customLightGray
    }
    
    private var selected: Bool {
        option == selectedOption
    }
}
