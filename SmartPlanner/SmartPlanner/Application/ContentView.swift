//
//  ContentView.swift
//  SmartPlanner
//
//  Created by 袁哲奕 on 2024/12/7.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    
    @State private var isShowingCalendar = false
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                if isShowingCalendar {
                    SPCalendarView()
                } else {
                    // 主视图内容
                    Text("主视图")
                        .navigationBarItems(trailing: calendarButton)
                }
            }
        }
    }
    
    // MARK: - Views
    
    private var calendarButton: some View {
        Button(action: { isShowingCalendar = true }) {
            Image(systemName: "calendar")
                .imageScale(.large)
                .foregroundColor(themeManager.getThemeColor(.primaryText))
        }
    }
}

// MARK: - Preview

#Preview("浅色模式") {
    ContentView()
        .environmentObject(ThemeManager.shared)
}

#Preview("深色模式") {
    ContentView()
        .environmentObject(ThemeManager.shared)
        .preferredColorScheme(.dark)
}
