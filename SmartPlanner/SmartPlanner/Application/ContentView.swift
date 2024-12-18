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
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 主视图
            SPCalendarView(
                selectedDate: $selectedDate,
                isShowingDayView: $isShowingDayView
            )
            
            // 底部工具栏
            SPCalendarToolbar(
                isShowingDayView: isShowingDayView,
                onTodayButtonTapped: scrollToToday,
                onViewModeButtonTapped: { isShowingDayView.toggle() },
                onInboxButtonTapped: {}
            )
            .padding(.bottom, 16)
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
