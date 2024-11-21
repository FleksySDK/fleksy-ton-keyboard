//  FullAccessKeyboardApp.swift
//  Keyboard
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI
import FleksyAppsCore

class FullAccessKeyboardApp: KeyboardApp {
    
    static var appId: String { Constants.FullAccessKeyboardAppId }
    
    var appId: String { Self.appId }
    
    func appIcon() -> UIImage? { nil }
    
    private var listener: AppListener?
    
    func initialize(listener: AppListener, configuration: AppConfiguration) {
        self.listener = listener
    }
    
    private var hostingController: UIHostingController<ActionKeyboardAppView>?
    
    func open(viewMode: KeyboardAppViewMode, theme: AppTheme) -> UIView? {
        let appView = ActionKeyboardAppView(buttonTitle: "Enable Full Access", theme: theme) { [weak self] in
            self?.openSettings()
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
        listener?.hide()
    }
    
    @MainActor private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              var responder: UIResponder = hostingController?.view
        else { return }
        
        let selector = sel_registerName("openURL:")
        while let nextResponder = responder.next {
            NSLog("responder = %@", nextResponder)
            if nextResponder.responds(to: selector) {
                nextResponder.performSelector(inBackground: selector, with: url)
                return
            }
            responder = nextResponder
        }
    }
}
