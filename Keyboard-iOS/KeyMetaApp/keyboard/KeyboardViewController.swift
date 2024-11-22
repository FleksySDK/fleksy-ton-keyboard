//  KeyboardViewController.swift
//  Keyboard
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import FleksySDK
import Combine
import FleksyAppsCore


func moveFile(from sourceURL: URL, to destinationURL: URL) {
    let fileManager = FileManager.default
    
    do {
        // Ensure the destination folder exists
        let destinationFolder = destinationURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: destinationFolder.path) {
            try fileManager.createDirectory(at: destinationFolder, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Move the file
        try fileManager.moveItem(at: sourceURL, to: destinationURL)
        print("File moved successfully from \(sourceURL.path) to \(destinationURL.path)")
    } catch {
        print("Error moving file: \(error)")
    }
}



class KeyboardViewController: FKKeyboardViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !hasFullAccess {
            openApp(appId: FullAccessKeyboardApp.appId)
        }
    }
    
    private func getLicenseConfiguration() -> LicenseConfiguration {
        guard
            let licenseKey = Bundle.main.object(forInfoDictionaryKey: "SDKLicenseKey") as? String,
            let licenseSecret = Bundle.main.object(forInfoDictionaryKey: "SDKLicenseSecret") as? String else {
            fatalError("Please, create the file SDKCredentials.xcconfig and add the license key and license secret for the SDK_LICENSE_KEY and SDK_LICENSE_SECRET configuration keys")
        }
        
        return LicenseConfiguration(licenseKey: licenseKey, licenseSecret: licenseSecret)
    }
    
    
    private func getStyleConfiguration() -> StyleConfiguration {
        
        // Create StyleConfiguration object
        return StyleConfiguration(spacebarLogoImage:UIImage(named: "SpacebarLogoKeyMeta"), spacebarStyle: .spacebarStyle_LogoOnly, spacebarLogoContentMode: .scaleAspectFit)
    }

    override func createConfiguration() -> KeyboardConfiguration {
        
        var keyboardApps: [KeyboardApp] = []
        
        if !hasFullAccess {
            keyboardApps.append(FullAccessKeyboardApp())
        }
        
        // Validate that the text written by the person is actual text and there is a person behind it.
        //
        let dataConfig = FLDataConfiguration()
        let dataValidation = CaptureConfiguration(true, output: enumCaptureOutput.captureOutput_file, dataConfig: dataConfig)
        
        let appsConfig = AppsConfiguration(keyboardApps: keyboardApps, showAppsInCarousel: false)
        return KeyboardConfiguration(   capture:dataValidation,
                                     style: getStyleConfiguration(),
                                     apps: appsConfig,
                                     license: getLicenseConfiguration())
    }
    
    override func dataCollectionStored(_ path: String, sessionId: String) {
        let sourceURL = URL(fileURLWithPath: path)
        
        if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.thingthing.KeyMeta"){
            
            let sharedResourcesURL = sharedContainerURL.appendingPathComponent("Resources/logger_typing_validate.log")
            moveFile(from: sourceURL, to: sharedResourcesURL)
        }
    }
        
    override var appIcon: UIImage? { nil }
    
}

    
