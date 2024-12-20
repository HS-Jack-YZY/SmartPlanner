import SwiftUI

struct SPMonthCalendarView: View {
    // MARK: - Properties
    
    @EnvironmentObject private var themeManager: ThemeManager
    private let month: Date
    private let calendar: Calendar
    private let daysInWeek = 7
    private let cellHeight: CGFloat = 80
    private let today = Date()
    
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 0),
        count: 7
    )
    
    // MARK: - Initialization
    
    init(month: Date) {
        self.month = month
        self.calendar = Calendar.current
    }
    
    // MARK: - Helper Methods
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: today)
    }
    
    private func isCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: month, toGranularity: .month)
    }
    
    private func calculateRowsNeeded(for targetMonth: Date) -> Int {
        let interval = calendar.dateInterval(of: .month, for: targetMonth)!
        let firstDay = interval.start
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let adjustedFirstWeekday = (firstWeekday + 5) % 7 + 1
        
        let daysCount = calendar.range(of: .day, in: .month, for: targetMonth)!.count
        let totalCells = adjustedFirstWeekday - 1 + daysCount
        
        return Int(ceil(Double(totalCells) / Double(daysInWeek)))
    }
    
    private func daysInMonth(for targetMonth: Date) -> [Date?] {
        let interval = calendar.dateInterval(of: .month, for: targetMonth)!
        let firstDay = interval.start
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let adjustedFirstWeekday = (firstWeekday + 5) % 7 + 1
        
        let daysCount = calendar.range(of: .day, in: .month, for: targetMonth)!.count
        let rowsNeeded = calculateRowsNeeded(for: targetMonth)
        let totalCells = rowsNeeded * daysInWeek
        
        var dates = Array(repeating: nil as Date?, count: totalCells)
        
        for day in 0..<daysCount {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                let index = day + adjustedFirstWeekday - 1
                if index < totalCells {
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
    
    private func getFirstDayIndex(for dates: [Date?]) -> Int? {
        return dates.firstIndex { $0 != nil }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func monthTitleView(at index: Int, for targetMonth: Date, dates: [Date?]) -> some View {
        if let firstDayIndex = getFirstDayIndex(for: dates), index == firstDayIndex {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: cellHeight / 2)
                
                Text(monthString(from: targetMonth))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(isCurrentMonth(targetMonth) ?
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
    
    @ViewBuilder
    private func dayView(for date: Date?) -> some View {
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
                .frame(height: 46)
                
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 30)
                    .padding(.horizontal, 8)
            }
            .frame(height: cellHeight)
        } else {
            Color.clear
                .frame(height: cellHeight)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        let dates = daysInMonth(for: month)
        let rowsNeeded = calculateRowsNeeded(for: month)
        
        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: 0) {
                // 月份标题行
                ForEach(0..<daysInWeek, id: \.self) { index in
                    monthTitleView(at: index, for: month, dates: dates)
                }
                
                // 日期网格
                ForEach(dates.indices, id: \.self) { index in
                    dayView(for: dates[index])
                }
            }
        }
        .frame(height: CGFloat(rowsNeeded + 1) * cellHeight)
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview

#Preview("当前月份") {
    SPMonthCalendarView(month: Date())
        .environmentObject(ThemeManager.shared)
}

#Preview("下个月（浅色）") {
    SPMonthCalendarView(month: Calendar.current.date(byAdding: .month, value: 1, to: Date())!)
        .environmentObject(ThemeManager.shared)
}

#Preview("下个月（深色）") {
    SPMonthCalendarView(month: Calendar.current.date(byAdding: .month, value: 1, to: Date())!)
        .environmentObject(ThemeManager.shared)
        .preferredColorScheme(.dark)
}
