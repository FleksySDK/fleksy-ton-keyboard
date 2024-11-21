//  KeyboardSettingsView.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI

struct KeyboardSettingsView: View {
    
    @ObservedObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.sections) { section in
                    Section(section.titleKey ?? "") {
                        ForEach(section.settings) { setting in
                            BoolSettingItem(keyboardSetting: setting)
                        }
                    }
                }
            }
            .navigationTitle("Keyboard settings")
        }
        .navigationViewStyle(.stack)
        .onReceive(NotificationCenter.default.publisher(for: UIScene.willEnterForegroundNotification), perform: { _ in
            viewModel.appWillEnterForeground()
        })
    }
}

private extension KeyboardSettingsView {
    
    class ViewModel: ObservableObject {
        
        let sections = KeyboardSettingSection.allSections
        func appWillEnterForeground() {
            sections.forEach {
                $0.refreshSettings()
            }
        }
    }
}

#Preview {
    KeyboardSettingsView()
}
