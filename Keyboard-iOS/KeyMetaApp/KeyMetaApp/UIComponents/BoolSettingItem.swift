//  BoolSettingItem.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI

struct BoolSettingItem: View {
    
    @ObservedObject private var setting: KeyboardSetting
    
    init(keyboardSetting: KeyboardSetting) {
        self.setting = keyboardSetting
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle(setting.titleKey, isOn: $setting.value)
                .font(.body)
                .foregroundStyle(.primary)
                .tint(.accent)
            if let subtitleKey = setting.subtitleKey {
                Text(subtitleKey)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    List {
        BoolSettingItem(keyboardSetting: KeyboardSetting(titleKey: "My setting",
                                                         subtitleKey: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                                                         get: { true }, set: { _ in }))
    }
}
