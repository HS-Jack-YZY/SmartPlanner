//
//  SmartPlannerApp.swift
//  SmartPlanner
//
//  Created by 袁哲奕 on 2024/12/7.
//

import SwiftUI

@main
struct SmartPlannerApp: App {
    // MARK: - Properties
    
    @StateObject private var themeManager = ThemeManager.shared
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
        }
    }
}
