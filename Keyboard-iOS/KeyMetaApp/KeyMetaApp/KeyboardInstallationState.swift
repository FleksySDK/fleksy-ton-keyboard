//  KeyboardInstallationState.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI
import UIKit
import FleksySDK

class KeyboardInstallationState: ObservableObject, Observable {
    @Published private(set) var KeyMetaInstalled: Bool
    @Published private(set) var fullAccessGranted: Bool
    
    init() {
        self.KeyMetaInstalled = KeyboardInstallationState.isKeyboardInstalled()
        self.fullAccessGranted = KeyboardInstallationState.hasKeyboardFullAccess()
    }
    
    func refreshState() {
        self.KeyMetaInstalled = KeyboardInstallationState.isKeyboardInstalled()
        self.fullAccessGranted = KeyboardInstallationState.hasKeyboardFullAccess()
    }
    
    private static func isKeyboardInstalled() -> Bool {
        FleksyExtensionSetupStatus.isAddedToSettingsKeyboardExtension(withBundleId: "co.thingthing.KeyMeta.keyboard")
    }
    
    private static func hasKeyboardFullAccess() -> Bool {
        UIInputViewController().hasFullAccess
    }
}
