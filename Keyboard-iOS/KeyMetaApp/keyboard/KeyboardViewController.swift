//  KeyboardViewController.swift
//  Keyboard
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import FleksySDK
import Combine
import FleksyAppsCore

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
        
        let darkTheme = StyleConfiguration.defaultDarkKeyboardTheme
        
        // Create dark KeyboardTheme from JSON file
        //let darkThemeJSONFilepath = Bundle.main.path(forResource: "darkTheme", ofType: "json")!
        //let darkThemeJSON = try! String(contentsOfFile: darkThemeJSONFilepath)
        //let darkTheme = KeyboardTheme(jsonString: darkThemeJSON)!
        
        // Create StyleConfiguration object
        return StyleConfiguration(spacebarLogoImage:UIImage(named: "SpacebarLogoKeyMeta"), spacebarStyle: .spacebarStyle_LogoOnly, spacebarLogoContentMode: .scaleAspectFit)
    }

    override func createConfiguration() -> KeyboardConfiguration {
        
        var keyboardApps: [KeyboardApp] = []
        
        if !hasFullAccess {
            keyboardApps.append(FullAccessKeyboardApp())
        }
        
        let appsConfig = AppsConfiguration(keyboardApps: keyboardApps, showAppsInCarousel: false)
        return KeyboardConfiguration(style: getStyleConfiguration(),
                                     apps: appsConfig,
                                     license: getLicenseConfiguration())
    }
    
    override var appIcon: UIImage? { nil }
}
