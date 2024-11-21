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
    
    /// Required to init as soon as possible to always refresh the latest subscription
    private static let sharedStore = SubscriptionStore()
    private var latestSubscriptionStatus: RenewalState? = Preferences.latestSubscriptionStatus.map { RenewalState(rawValue: $0) } {
        didSet {
            if oldValue.isSubscribed != latestSubscriptionStatus.isSubscribed {
                reloadConfiguration()
            }
        }
    }
    
    private var observation: AnyCancellable?
    override func viewDidLoad() {
        let _ = Self.sharedStore
        super.viewDidLoad()
        observation = Preferences.$latestSubscriptionStatus.sink { [weak self] (newStatus: RenewalState.RawValue?) in
            self?.latestSubscriptionStatus = newStatus.map { RenewalState(rawValue: $0) }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !hasFullAccess {
            openApp(appId: FullAccessKeyboardApp.appId)
        } else if !latestSubscriptionStatus.isSubscribed && SubscribeKeyboardAppTracker.shared.shouldOpen() {
            openApp(appId: SubscribeKeyboardApp.appId)
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
        // Default light KeyboardTheme
        let lightTheme = StyleConfiguration.defaultLightKeyboardTheme
        
        // Create dark KeyboardTheme from JSON file
        let darkThemeJSONFilepath = Bundle.main.path(forResource: "darkTheme", ofType: "json")!
        let darkThemeJSON = try! String(contentsOfFile: darkThemeJSONFilepath)
        let darkTheme = KeyboardTheme(jsonString: darkThemeJSON)!
        
        // Create StyleConfiguration object
        return StyleConfiguration(theme: darkTheme, darkTheme: darkTheme, spacebarLogoImage: UIImage(named: "SpacebarLogo"), spacebarStyle: .spacebarStyle_LogoOnly, spacebarLogoContentMode: .scaleAspectFit)
    }

    override func createConfiguration() -> KeyboardConfiguration {
        
        var keyboardApps: [KeyboardApp] = []
        
        if !hasFullAccess {
            keyboardApps.append(FullAccessKeyboardApp())
        } else if !latestSubscriptionStatus.isSubscribed, SubscribeKeyboardAppTracker.shared.shouldOpen() {
            keyboardApps.append(SubscribeKeyboardApp())
        }
        
        let appsConfig = AppsConfiguration(keyboardApps: keyboardApps, showAppsInCarousel: false)
        return KeyboardConfiguration(style: getStyleConfiguration(),
                                     apps: appsConfig,
                                     license: getLicenseConfiguration())
    }
    
    override var appIcon: UIImage? { nil }
}
