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
    @State private var currentMonth = Date()
    @State private var isShowingDayView = false
    @State private var isShowingCalendar = false
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // 主视图
                VStack(spacing: 0) {
                    // 日历视图
                    SPCalendarView(
                        selectedDate: $selectedDate,
                        isShowingDayView: $isShowingDayView
                    )
                }
                
                // 底部工具栏
                SPCalendarToolbar(
                    isShowingDayView: isShowingDayView,
                    onTodayButtonTapped: scrollToToday,
                    onViewModeButtonTapped: toggleViewMode,
                    onInboxButtonTapped: showInbox
                )
                .padding(.bottom, 16)
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Private Methods
    
    private func scrollToToday() {
        withAnimation {
            selectedDate = Date()
            currentMonth = Date()
        }
    }
    
    private func toggleViewMode() {
        withAnimation {
            isShowingDayView.toggle()
        }
    }
    
    private func showInbox() {
        // TODO: 实现收件箱功能
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 浅色模式预览
            ContentView()
                .environmentObject(ThemeManager.shared)
                .previewDisplayName("浅色模式")
            
            // 深色模式预览
            ContentView()
                .environmentObject(ThemeManager.shared)
                .preferredColorScheme(.dark)
                .previewDisplayName("深色模式")
        }
    }
}
