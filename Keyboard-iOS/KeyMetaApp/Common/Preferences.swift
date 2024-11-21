//  Preferences.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import Foundation
import StoreKit

extension UserDefaults {
    
    static let appGroup: UserDefaults = {
        guard let appGroupName = Bundle.main.infoDictionary?["AppGroupName"] as? String,
              let defaults = UserDefaults(suiteName: appGroupName)
        else {
            fatalError("Error: setup the shared app group and add the shared group identifier for the `AppGroupName` key in the info.plist")
        }
        return defaults
    }()
}

final class Preferences {
    
    @UserDefault(key: "co.thingthing.KeyMeta.subscription.latestStatus",
                 UserDefaults.appGroup)
    static var latestSubscriptionStatus: RenewalState.RawValue?
}
