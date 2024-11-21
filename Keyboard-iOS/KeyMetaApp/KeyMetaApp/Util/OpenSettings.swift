//  OpenSettings.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import UIKit

@MainActor func openSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
