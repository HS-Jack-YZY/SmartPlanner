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
    @State private var isEditingDate = false
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 主视图容器
            VStack(spacing: 0) {
                // 导航栏
                SPCalendarNavigationBar(
                    currentMonth: selectedDate,
                    isEditing: $isEditingDate,
                    onPreviousMonth: { moveMonth(by: -1) },
                    onNextMonth: { moveMonth(by: 1) },
                    onDateSelected: handleDateSelected
                )
                
                // 内容视图
                SPCalendarView(
                    selectedDate: $selectedDate,
                    isShowingDayView: $isShowingDayView
                )
            }
            
            // 底部工具栏（始终在最顶层）
            VStack {
                Spacer()
                SPBottomToolbar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
    
    // MARK: - Private Methods
    
    private func moveMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func handleDateSelected(_ date: Date) {
        selectedDate = date
        isEditingDate = false
    }
    
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
