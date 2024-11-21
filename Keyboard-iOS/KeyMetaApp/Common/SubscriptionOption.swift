//  SubscriptionOption.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI
import StoreKit

struct SubscriptionOptionMetadata: Decodable {
    
    static let all: [SubscriptionOptionMetadata] = {
        let metadataPlistURL = Bundle.main.url(forResource: "MediKeyStoreMetadata", withExtension: "plist")!
        do {
            let data = try Data(contentsOf: metadataPlistURL)
            return try PropertyListDecoder().decode([SubscriptionOptionMetadata].self, from: data)
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
        
    private let periodKey: String
    private let titleKey: String
    let productID: String
    
    var period: String {
        NSLocalizedString(periodKey, comment: "")
    }
    
    var title: String {
        NSLocalizedString(titleKey, comment: "")
    }
}

protocol SubscriptionOption: Equatable {
    
    var title: String { get }
    var subtitle: String { get }
}

extension Product: SubscriptionOption {
    
    private var metadata: SubscriptionOptionMetadata? {
        SubscriptionOptionMetadata.all.first { $0.productID == id }
    }
    
    var title: String {
        metadata?.title ?? displayName
    }
    
    var subtitle: String {
        guard let metadata else {
            return displayPrice
        }
        return "\(displayPrice) / \(metadata.period)"
    }
}
