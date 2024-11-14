//
//  KeyboardViewController.swift
//  keyboard
//
//  Copyright © 2024 Thingthing,Ltd. All rights reserved.
//  Licensed under the MIT license. See LICENSE file in the project root for details
//

import UIKit
import FleksyKeyboardSDK

// MARK: - KeyboardViewController

class KeyboardViewController: FKKeyboardViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var appIcon: UIImage?{
        return nil
    }
    
    override func createConfiguration() -> KeyboardConfiguration {
        

        let licenseConfig = LicenseConfiguration(licenseKey: "your-license-key", licenseSecret: "your-license-secret")
        
        //
        // Create the configuration for the keyboard
        //
        return KeyboardConfiguration(license: licenseConfig)
    }
}
