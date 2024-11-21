//  KeyMetaApp.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI

@main
struct KeyMetaApp: App {
    
    private enum Tab: Hashable {
        case home
        case settings
        case about
    }
    
    @StateObject private var installationState = KeyboardInstallationState()
    
    // Initialize the Store at app launch to start listening to transactions ASAP
    @StateObject var store = SubscriptionStore()
    
    @State private var showUpgradeSheet: Bool = false
    @State private var openedTab: Tab?
    
    var body: some Scene {
        WindowGroup {
            Group {
                if installationState.KeyMetaInstalled {
                    TabView() {
                        HomeView()
                            .tabItem {
                                Label("Home", systemImage: "house")
                            }
                            .environmentObject(store)
                            .environmentObject(installationState)
                            .tag(Tab.home)
                        if installationState.fullAccessGranted {
                            KeyboardSettingsView()
                                .tabItem {
                                    Label("Settings", systemImage: "gearshape")
                                }
                                .tag(Tab.settings)
                        }
                        AboutAppView()
                            .tabItem {
                                //TODO: Add final title and logo
                                Label("About", systemImage: "questionmark.circle")
                            }
                            .environmentObject(store)
                            .tag(Tab.about)
                    }
                } else {
                    OnboardingView()
                        .environmentObject(installationState)
                }
            }
            .onAppear {
                installationState.refreshState()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIScene.willEnterForegroundNotification), perform: { _ in
                installationState.refreshState()
            })
            .onOpenURL { url in
                if url == Constants.subscriptionDeepLinkURL {
                    openedTab = .home
                    if !store.subscriptionGroupStatus.isSubscribed {
                        showUpgradeSheet = true
                    }
                }
            }
        }
    }
}
