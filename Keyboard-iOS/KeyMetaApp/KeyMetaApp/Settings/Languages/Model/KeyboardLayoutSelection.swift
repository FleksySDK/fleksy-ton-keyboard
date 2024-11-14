//
//  KeyboardLayoutSelection.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing,Ltd. All rights reserved.
//  Licensed under the MIT license. See LICENSE file in the project root for details
//

import Foundation


struct KeyboardLayoutItem: SelectionItem {
    let layout: String
    var titleKey: String {
        layout
    }
    let subtitleKey: String? = nil
    var value: SelectionItemValue {
        .string(titleKey)
    }
    let modificator: ItemModificator? = nil
}

struct KeyboardLayoutSelection: Selectable {
    let languageName: String?
    let languageCode: String
    let items: [SelectionItem]
    
    init(languageName: String?, languageCode: String) {
        self.languageName = languageName
        self.languageCode = languageCode
        self.items = LanguagesManager.shared.getAvailableLayoutsForLanguage(languageCode).map {
            KeyboardLayoutItem(layout: $0)
        }
    }
    
    var titleKey: String { languageName ?? languageCode }
    let subtitleKey: String? = nil
    
    let allowsSorting = false
    
    func setSelected(_ item: SelectionItem) {
        guard case .string(let string) = item.value else {
            return
        }
        LanguagesManager.shared.setCurrentLayout(string, for: languageCode)
    }
    
    func getSelected() -> SelectionItem? {
        return LanguagesManager.shared.getCurrentLayout(forLanguage: languageCode).map {
            KeyboardLayoutItem(layout: $0)
        }
    }
}
