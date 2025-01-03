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
    @State private var isShowingDayView = true
    @State private var selectedTab = 0
    @State private var isEditingDate = false
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 导航栏
            SPNavigationBar(
                currentMonth: selectedDate,
                isEditing: $isEditingDate,
                viewMode: isShowingDayView ? .day : .month,
                onPreviousMonth: { moveMonth(by: -1) },
                onNextMonth: { moveMonth(by: 1) },
                onDateSelected: { date, shouldExitEditing in
                    handleDateSelected(date, shouldExitEditing: shouldExitEditing)
                },
                onBackToMonth: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowingDayView = false
                    }
                }
            )
            
            // 内容视图
            ZStack {
                SPCalendarView(
                    selectedDate: $selectedDate,
                    isShowingDayView: $isShowingDayView
                )
                
                // 编辑模式遮罩层（只覆盖内容区域）
                if isEditingDate {
                    Color.black.opacity(0.01) // 几乎透明的遮罩
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                isEditingDate = false
                            }
                        }
                }
            }
            
            // 底部工具栏
            SPBottomToolbar(selectedTab: $selectedTab)
                .background(themeManager.getThemeColor(.secondaryBackground))
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    // MARK: - Private Methods
    
    private func moveMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func handleDateSelected(_ date: Date, shouldExitEditing: Bool) {
        selectedDate = date
        if shouldExitEditing {
            withAnimation(.easeOut(duration: 0.2)) {
                isEditingDate = false
            }
        }
    }
    
    private func scrollToToday() {
        selectedDate = Date()
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(ThemeManager.shared)
}
