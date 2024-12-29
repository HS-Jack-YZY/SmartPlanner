import SwiftUI

struct SPMonthCalendarView: View {
    // MARK: - Properties
    
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedDate: Date?
    let month: Date
    let onDateSelected: (Date) -> Void
    
    private let calendar: Calendar
    private let daysInWeek = 7
    private let cellHeight: CGFloat = 80 // 固定单元格高度
    private let today = Date() // 当前日期
    
    // MARK: - Initialization
    
    init(month: Date = Date(), onDateSelected: @escaping (Date) -> Void) {
        self.month = month
        self.onDateSelected = onDateSelected
        self.calendar = Calendar.current
    }
    
    // MARK: - Helper Methods
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: today)
    }
    
    private func isCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: month, toGranularity: .month)
    }
    
    private func daysInMonth() -> [Date?] {
        let interval = calendar.dateInterval(of: .month, for: month)!
        let firstDay = interval.start
        
        // 获取月份第一天是周几（0是周日）
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        // 调整为周一开始（1是周一）
        let adjustedFirstWeekday = (firstWeekday + 5) % 7 + 1
        
        let daysCount = calendar.range(of: .day, in: .month, for: month)!.count
        
        var dates: [Date?] = Array(repeating: nil, count: 42)
        
        // 只添加当前月的日期
        for day in 0..<daysCount {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                let index = day + adjustedFirstWeekday - 1
                if index < 42 {
                    dates[index] = date
                }
            }
        }
        
        return dates
    }
    
    private func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    private func getFirstDayIndex() -> Int? {
        return daysInMonth().firstIndex { $0 != nil }
    }
    
    private func getDatesForRow(_ row: Int) -> [Date?] {
        let startIndex = row * daysInWeek
        let dates = daysInMonth()
        return Array(dates[startIndex..<startIndex + daysInWeek])
    }
    
    private func getTotalRows() -> Int {
        let dates = daysInMonth()
        let lastDateIndex = dates.lastIndex { $0 != nil } ?? 0
        return (lastDateIndex / daysInWeek) + 1
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                // 月份标题行
                GridRow {
                    ForEach(0..<daysInWeek) { index in
                        if let firstDayIndex = getFirstDayIndex(), index == firstDayIndex {
                            VStack(spacing: 0) {
                                Spacer()
                                    .frame(height: cellHeight / 2)
                                
                                Text(monthString(from: month))
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(isCurrentMonth(month) ? 
                                        themeManager.getThemeColor(.calendarTodayText) :
                                        themeManager.getThemeColor(.primaryText))
                                    .font(.headline)
                                    .padding(.bottom, 8)
                            }
                            .frame(height: cellHeight)
                        } else {
                            Color.clear
                                .frame(height: cellHeight)
                        }
                    }
                }
                
                // 日期网格
                let totalRows = getTotalRows()
                ForEach(0..<totalRows) { row in
                    GridRow {
                        ForEach(getDatesForRow(row), id: \.self) { date in
                            if let currentDate = date {
                                VStack(spacing: 0) {
                                    ZStack {
                                        if isToday(currentDate) {
                                            Circle()
                                                .fill(themeManager.getThemeColor(.calendarTodayText))
                                                .frame(width: 30, height: 30)
                                        }
                                        
                                        Text("\(calendar.component(.day, from: currentDate))")
                                            .foregroundColor(isToday(currentDate) ?
                                                .white :
                                                themeManager.getThemeColor(.primaryText))
                                            .font(isToday(currentDate) ? .headline : .body)
                                    }
                                    .frame(height: 46)  // 固定日期部分高度
                                    .onTapGesture {
                                        onDateSelected(currentDate)
                                    }
                                    
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(height: 30)  // 固定指示器高度
                                        .padding(.horizontal, 8)
                                }
                                .frame(height: cellHeight)
                            } else {
                                Color.clear
                                    .frame(height: cellHeight)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Preview

#Preview("当前月份") {
    // 当前月份（浅色主题）
    SPMonthCalendarView(onDateSelected: { _ in })
        .environmentObject(ThemeManager.shared)
}

#Preview("下个月（浅色）") {
    // 下个月（浅色主题）
    SPMonthCalendarView(
        month: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
        onDateSelected: { _ in }
    )
    .environmentObject(ThemeManager.shared)
}

#Preview("下个月（深色）") {
    // 下个月（深色主题）
    SPMonthCalendarView(
        month: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
        onDateSelected: { _ in }
    )
    .environmentObject(ThemeManager.shared)
    .preferredColorScheme(.dark)
}
