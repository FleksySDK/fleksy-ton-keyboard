//  SubscribeKeyboardApp.swift
//  Keyboard
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI
import FleksyAppsCore

/// Keyboard app that should open automatically when the user has not bought a subscription.
///
/// Note that the keyboard app is not to be shown every time the keyboard opens.
/// The `SubscribeKeyboardAppTracker` contains the logic for when to open the keyboard app.
class SubscribeKeyboardApp: KeyboardApp {
    
    static var appId: String { Constants.SubscribeKeyboardAppId }
    
    var appId: String { Self.appId }
    
    func appIcon() -> UIImage? { nil }
    
    private var listener: AppListener?
    
    func initialize(listener: AppListener, configuration: AppConfiguration) {
        self.listener = listener
    }
    
    private var hostingController: UIHostingController<ActionKeyboardAppView>?
    
    func open(viewMode: KeyboardAppViewMode, theme: AppTheme) -> UIView? {
        let appView = ActionKeyboardAppView(buttonTitle: "Unlock MediKey's full potential", theme: theme) { [weak self] in
            self?.openUpgradeScreenInApp()
        } onCloseAction: { [weak self] in
            self?.onCloseAction()
        }

        let hostingController = UIHostingController(rootView: appView)
        self.hostingController = hostingController
        hostingController.view.backgroundColor = .clear
        return hostingController.view
    }
    
    func onThemeChanged(_ theme: FleksyAppsCore.AppTheme) {
        hostingController?.rootView.theme = theme
    }
    
    var defaultViewMode: KeyboardAppViewMode {
        .frame(barMode: .default, height: .automatic)
    }
    
    // MARK: - Private methods
        
    @MainActor private func onCloseAction() {
        SubscribeKeyboardAppTracker.shared.trackAppClosedManually()
        listener?.hide()
    }
    
    @MainActor private func openUpgradeScreenInApp() {
        guard var responder: UIResponder = hostingController?.view
        else { return }
        
        let selector = sel_registerName("openURL:")
        while let nextResponder = responder.next {
            NSLog("responder = %@", nextResponder)
            if nextResponder.responds(to: selector) {
                nextResponder.performSelector(inBackground: selector, with: Constants.subscriptionDeepLinkURL)
                return
            }
            responder = nextResponder
        }
    }
}
