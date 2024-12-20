//
//  ContentView.swift
//  SmartPlanner
//
//  Created by 袁哲奕 on 2024/12/7.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    
    @State private var selectedDate = Date()
    @State private var isShowingDayView = false
    @State private var selectedTab = 0
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 主视图
            SPCalendarView(
                selectedDate: $selectedDate,
                isShowingDayView: $isShowingDayView
            )
            
            // 底部工具栏（始终在最顶层）
            VStack {
                Spacer()
                SPBottomToolbar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
    
    // MARK: - Private Methods
    
    private func scrollToToday() {
        selectedDate = Date()
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ThemeManager.shared)
    }
}
