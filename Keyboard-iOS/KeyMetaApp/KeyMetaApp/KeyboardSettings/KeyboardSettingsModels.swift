//  KeyboardSettingsModels.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI
import FleksySDK

class KeyboardSetting: ObservableObject, Identifiable {
    let id = UUID()
    let titleKey: LocalizedStringKey
    let subtitleKey: LocalizedStringKey?
    let getter: () -> Bool
    let setter: (Bool) -> Void
    
    @Published var value: Bool {
        didSet {
            setter(value)
        }
    }
    
    func refresh() {
        value = getter()
    }
    
    init(titleKey: LocalizedStringKey, subtitleKey: LocalizedStringKey? = nil, get: @escaping () -> Bool, set: @escaping (Bool) -> Void) {
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.getter = get
        self.setter = set
        self.value = getter()
    }
}


struct KeyboardSettingSection: Identifiable {
    let id = UUID()
    
    let titleKey: LocalizedStringKey?
    let settings: [KeyboardSetting]
    
    func refreshSettings() {
        settings.forEach {
            $0.refresh()
        }
    }
    
    init(titleKey: LocalizedStringKey? = nil, settings: [KeyboardSetting]) {
        self.titleKey = titleKey
        self.settings = settings
    }
    
    static let allSections: [KeyboardSettingSection] = [
        KeyboardSettingSection(settings: [
            KeyboardSetting(titleKey: "Auto-Correction",
                            get: { FleksyManagedSettings.autoCorrection },
                            set: { FleksyManagedSettings.autoCorrection = $0 }),
            KeyboardSetting(titleKey: "Auto-Capitalization",
                            get: { FleksyManagedSettings.autoCapitalization },
                            set: { FleksyManagedSettings.autoCapitalization = $0 }),
            KeyboardSetting(titleKey: "Swipe Typing",
                            get: { FleksyManagedSettings.swipeTyping },
                            set: { FleksyManagedSettings.swipeTyping = $0 }),
            KeyboardSetting(titleKey: "Undo Auto-Correction",
                            subtitleKey: "Tapping the backspace key after autocorrect will undo autocorrection.",
                            get: { FleksyManagedSettings.backspaceToUndoAutoCorrection },
                            set: { FleksyManagedSettings.backspaceToUndoAutoCorrection = $0 }),
        ]),
        KeyboardSettingSection(settings: [
            KeyboardSetting(titleKey: "Sound Feedback on keypress",
                            get: { FleksyManagedSettings.soundMode == .sound() },
                            set: { FleksyManagedSettings.soundMode = $0 ? .sound() : .silent }),
            KeyboardSetting(titleKey: "Haptic Feedback on keypress",
                            get: { FleksyManagedSettings.haptics },
                            set: { FleksyManagedSettings.haptics = $0 }),
        ]),
        KeyboardSettingSection(settings: [
            KeyboardSetting(titleKey: "\".\" Shortcut",
                            subtitleKey: "Double tapping the space bar will insert a period followed by a space",
                            get: { FleksyManagedSettings.doubleSpaceTapAddsPunctuation },
                            set: { FleksyManagedSettings.doubleSpaceTapAddsPunctuation = $0 }),
        ]),
        KeyboardSettingSection(settings: [
            KeyboardSetting(titleKey: "Number Row",
                            get: { FleksyManagedSettings.numberRow },
                            set: { FleksyManagedSettings.numberRow = $0 }),
            KeyboardSetting(titleKey: "Emoji Suggestion",
                            get: { FleksyManagedSettings.emojiPredictions },
                            set: { FleksyManagedSettings.emojiPredictions = $0 }),
        ]),
    ]
}
