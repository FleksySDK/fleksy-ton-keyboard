//  KeyboardViewController.swift
//  Keyboard
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import FleksySDK
import Combine
import FleksyAppsCore
import MediaShareApp


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
    
    private lazy var licenseKey: String = {
        guard let licenseKey = Bundle.main.object(forInfoDictionaryKey: "SDKLicenseKey") as? String else {
            fatalError("Please, make sure that a SDK license key is set for the SDKLicenseKey key in the keyboard extension's info.plist file")
        }
        return licenseKey
    }()
    
    private lazy var licenseSecret: String = {
        guard let licenseKey = Bundle.main.object(forInfoDictionaryKey: "SDKLicenseSecret") as? String else {
            fatalError("Please, make sure that a SDK license secret is set for the SDKLicenseSecret key in the keyboard extension's info.plist file")
        }
        return licenseKey
    }()
    
    private lazy var mediaShareApiKey: String = {
        guard let mediaShareApiKey = Bundle.main.object(forInfoDictionaryKey: "MediaShareAppApiKey") as? String else {
            fatalError("Please, make sure that a MediaShare App API key is set for the MEDIA_SHARE_API_KEY key in the SDKCredentials.xcconfig file ")
        }
        return mediaShareApiKey
    }()
    
    private func getStyleConfiguration() -> StyleConfiguration {
        
        // Create StyleConfiguration object
        return StyleConfiguration(spacebarLogoImage:UIImage(named: "SpacebarLogoKeyMeta"), spacebarStyle: .spacebarStyle_LogoOnly, spacebarLogoContentMode: .scaleAspectFit)
    }
    
    private var keyMetaApp: PluginKeyMeta?
    private var mediaShareApp: MediaShareApp?
    
    private func getMediaShareApp() -> MediaShareApp {
        if let mediaShareApp {
            return mediaShareApp
        } else {
            let mediaShareApp = MediaShareApp(contentType: .gifs, apiKey: mediaShareApiKey, sdkLicenseKey: licenseKey, appIcon: UIImage(named: "IconGIF"))
            self.mediaShareApp = mediaShareApp
            return mediaShareApp
        }
    }
    
    private func getKeyMetaApp() -> PluginKeyMeta{
        if let keyMetaApp {
            return keyMetaApp
        } else {
            let keyMetaApp = PluginKeyMeta()
            self.keyMetaApp = keyMetaApp
            return keyMetaApp
        }
    }
    
    override func createConfiguration() -> KeyboardConfiguration {
        
        let keyboardApps: [KeyboardApp] = hasFullAccess ? [getMediaShareApp(), getKeyMetaApp()] : [FullAccessKeyboardApp()]
        
        // Validate that the text written by the person is actual text and there is a person behind it.
        //
        let dataConfig = FLDataConfiguration()
        let dataValidation = CaptureConfiguration(true,
                                                  output: enumCaptureOutput.captureOutput_file,
                                                  dataConfig: dataConfig)
        let styleConfig = StyleConfiguration(spacebarLogoImage:UIImage(named: "SpacebarLogoKeyMeta"),
                                             spacebarStyle: .spacebarStyle_LogoOnly,
                                             spacebarLogoContentMode: .scaleAspectFit)
        
        let appsConfig = AppsConfiguration(keyboardApps: keyboardApps,
                                           showAppsInCarousel: true)
        let licenseConfig = LicenseConfiguration(licenseKey: licenseKey,
                                                 licenseSecret: licenseSecret)
        return KeyboardConfiguration(capture:dataValidation,
                                     style: getStyleConfiguration(),
                                     apps: appsConfig,
                                     license: licenseConfig)
    }
    
    override func dataCollectionStored(_ path: String, sessionId: String) {
        let sourceURL = URL(fileURLWithPath: path)
        
        if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.thingthing.KeyMeta"){
            
            let sharedResourcesURL = sharedContainerURL.appendingPathComponent("Resources/logger_typing_validate.log")
            moveFile(from: sourceURL, to: sharedResourcesURL)
        }
    }
    
    override var appIcon: UIImage? {
        UIImage(named: "KeyboardIcon")
    }
    
    private lazy var gifMediaShareAppButton: UIButton = {
        var btnConfig = UIButton.Configuration.plain()
        btnConfig.image = mediaShareApp?.appIcon()?.withRenderingMode(.alwaysOriginal)
        btnConfig.title = nil
        let btn = UIButton(configuration: btnConfig)
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            self.openApp(appId: self.getMediaShareApp().appId)
        }
        btn.addAction(action, for: .touchUpInside)
        return btn
    }()
}
