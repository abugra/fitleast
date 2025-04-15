//
//  fitleastApp.swift
//  fitleast
//
//  Created by Ahmet Bugra Avcilar on 15.04.2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

@main
struct fitleastApp: App {
    init() {
        #if os(iOS)
        setupAppearance()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    #if os(iOS)
    private func setupAppearance() {
        // Use modern SwiftUI appearance API when running on iOS 15+
        if #available(iOS 15.0, *) {
            // iOS 15 and later has different appearance settings
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = .black
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        } else {
            // Fallback for older iOS versions
            UINavigationBar.appearance().barTintColor = .black
            UITabBar.appearance().barTintColor = .black
        }
    }
    #endif
}
