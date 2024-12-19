import SwiftUI

struct SPCalendarNavigationBar: View {
    // MARK: - Properties
    
    let onDismiss: () -> Void
    let isShowingDayView: Bool
    @Binding var currentMonth: Date
    @State private var isShowingMonthPicker = false
    @State private var visibleYearRange: Range<Int> = 2024..<2034  // 初始显示10年
    @EnvironmentObject private var themeManager: ThemeManager
    
    private let calendar = Calendar.current
    private let minYear = 2024
    private let maxYear = 2124
    private let weekdays = Calendar.current.shortWeekdaySymbols.rotateLeft(by: 1) // 从周一开始
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 导航栏内容
            HStack {
                // 年月选择按钮
                Button(action: { isShowingMonthPicker.toggle() }) {
                    HStack(spacing: 4) {
                        Text(monthYearString(from: currentMonth))
                            .foregroundColor(themeManager.getThemeColor(.primaryText))
                            .font(.headline)
                        Image(systemName: "chevron.right")
                            .imageScale(.small)
                            .foregroundColor(themeManager.getThemeColor(.primaryText))
                            .rotationEffect(.degrees(isShowingMonthPicker ? 90 : 0))
                    }
                }
                
                Spacer()
                
                // 返回按钮
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
                        .opacity(0.6)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // 月份选择器
            if isShowingMonthPicker {
                monthYearPicker
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // 底部分隔线
            Divider()
                .background(themeManager.getThemeColor(.calendarToolbarTint).opacity(0.2))
            
            // 星期标题行（仅在月视图模式下显示）
            if !isShowingDayView {
                weekdayHeader
                    .padding(.top, 8)
            }
        }
        .background(themeManager.getThemeColor(.secondaryBackground))
        .animation(.spring(response: 0.3), value: isShowingMonthPicker)
    }
    
    // MARK: - Views
    
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption)
                    .foregroundColor(themeManager.getThemeColor(.secondaryText))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
    
    private var monthYearPicker: some View {
        VStack(spacing: 0) {
            // 年份和月份选择器并排显示
            HStack(spacing: 0) {
                // 年份选择器
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(visibleYearRange, id: \.self) { year in
                                if let date = calendar.date(from: DateComponents(year: year, month: calendar.component(.month, from: currentMonth))) {
                                    yearButton(for: date)
                                        .id(year)
                                        .onAppear {
                                            // 当显示最后几年时，扩展年份范围
                                            if year >= visibleYearRange.upperBound - 2 && visibleYearRange.upperBound < maxYear {
                                                let newUpperBound = min(visibleYearRange.upperBound + 10, maxYear)
                                                visibleYearRange = visibleYearRange.lowerBound..<newUpperBound
                                            }
                                            // 当显示最前几年时，扩��年份范围
                                            if year <= visibleYearRange.lowerBound + 2 && visibleYearRange.lowerBound > minYear {
                                                let newLowerBound = max(visibleYearRange.lowerBound - 10, minYear)
                                                visibleYearRange = newLowerBound..<visibleYearRange.upperBound
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onAppear {
                        // 滚动到当前年份
                        let currentYear = calendar.component(.year, from: currentMonth)
                        proxy.scrollTo(currentYear, anchor: .center)
                    }
                }
                
                Divider()
                    .frame(height: 24)
                    .padding(.horizontal, 8)
                
                // 月份选择器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<12) { month in
                            if let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentMonth), month: month + 1)) {
                                monthButton(for: date)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Helper Views
    
    private func yearButton(for date: Date) -> some View {
        Button(action: {
            withAnimation {
                currentMonth = date
            }
        }) {
            Text(String(calendar.component(.year, from: date)))
                .foregroundColor(calendar.isDate(date, equalTo: currentMonth, toGranularity: .year) ?
                    themeManager.getThemeColor(.calendarTodayText) :
                    themeManager.getThemeColor(.primaryText))
                .font(.headline)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    calendar.isDate(date, equalTo: currentMonth, toGranularity: .year) ?
                        themeManager.getThemeColor(.calendarTodayText).opacity(0.1) :
                        Color.clear
                )
                .cornerRadius(6)
        }
    }
    
    private func monthButton(for date: Date) -> some View {
        Button(action: {
            withAnimation {
                currentMonth = date
                isShowingMonthPicker = false
            }
        }) {
            Text(monthString(from: date))
                .foregroundColor(calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) ?
                    themeManager.getThemeColor(.calendarTodayText) :
                    themeManager.getThemeColor(.primaryText))
                .font(.subheadline)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) ?
                        themeManager.getThemeColor(.calendarTodayText).opacity(0.1) :
                        Color.clear
                )
                .cornerRadius(6)
        }
    }
    
    // MARK: - Helper Methods
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Helper Methods

extension Array {
    func rotateLeft(by: Int) -> [Element] {
        guard count > 0, by > 0 else { return self }
        let by = by % count
        return Array(self[by...] + self[..<by])
    }
}

// MARK: - Preview

#Preview("浅色模式") {
    // 浅色模式预览
    SPCalendarNavigationBar(
        onDismiss: {},
        isShowingDayView: false,
        currentMonth: .constant(Date())
    )
    .environmentObject(ThemeManager.shared)
}

#Preview("深色模式") {
    // 深色模式预览
    SPCalendarNavigationBar(
        onDismiss: {},
        isShowingDayView: true,
        currentMonth: .constant(Date())
    )
    .environmentObject(ThemeManager.shared)
    .preferredColorScheme(.dark)
} 
