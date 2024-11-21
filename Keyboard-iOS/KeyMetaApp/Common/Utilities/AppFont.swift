//  AppFont.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI

// See https://developer.apple.com/design/human-interface-guidelines/typography
// for a guide on font sizes

extension Font {
    
    private static let customFontFamily = "SF Georgian Rounded"
    
    public static var customLargeTitle: Font {
        Font.custom(customFontFamily, size: 30, relativeTo: .largeTitle)
    }
    
    public static var customTitle: Font {
        Font.custom(customFontFamily, size: 24, relativeTo: .title)
    }
    
    public static var customTitle2: Font {
        Font.custom(customFontFamily, size: 20, relativeTo: .title2)
    }
    
    public static var customTitle3: Font {
        Font.custom(customFontFamily, size: 16, relativeTo: .title3)
    }
    
    public static var customBody: Font {
        Font.custom(customFontFamily, size: 14, relativeTo: .body)
    }
    
    public static var customFootnote: Font {
        Font.custom(customFontFamily, size: 12, relativeTo: .footnote)
    }
}
