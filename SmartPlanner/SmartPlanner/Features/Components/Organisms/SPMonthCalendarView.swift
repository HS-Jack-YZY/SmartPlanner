import SwiftUI

// MARK: - ScrollDirection

private enum ScrollDirection {
    case forward
    case backward
}

struct SPMonthCalendarView: View {
    // MARK: - Properties
    
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var visibleMonths: [Date] = []
    @State private var isLoadingMore = false
    @State private var scrolledToInitial = false
    
    private let month: Date
    private let calendar: Calendar
    private let daysInWeek = 7
    private let cellHeight: CGFloat = 80
    private let today = Date()
    private let initialMonthRange = (-2...2)
    
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
    
    private func initializeMonths() {
        visibleMonths = initialMonthRange.compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: month)
        }
    }
    
    private func scrollToMonth(_ targetMonth: Date, proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(targetMonth, anchor: .center)
        }
    }
    
    private func loadMoreMonths(direction: ScrollDirection) {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        
        DispatchQueue.global().async {
            let newMonths = generateNewMonths(direction: direction)
            DispatchQueue.main.async {
                withAnimation {
                    if direction == .forward {
                        visibleMonths.append(contentsOf: newMonths)
                    } else {
                        visibleMonths.insert(contentsOf: newMonths, at: 0)
                    }
                }
                isLoadingMore = false
            }
        }
    }
    
    private func generateNewMonths(direction: ScrollDirection) -> [Date] {
        let baseMonth = direction == .forward ? 
            visibleMonths.last ?? month : 
            visibleMonths.first ?? month
            
        return (1...3).compactMap { offset in
            calendar.date(
                byAdding: .month,
                value: direction == .forward ? offset : -offset,
                to: baseMonth
            )
        }
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: today)
    }
    
    private func isCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: month, toGranularity: .month)
    }
    
    private func calculateRowsNeeded(for targetMonth: Date) -> Int {
        let interval = calendar.dateInterval(of: .month, for: targetMonth)!
        let firstDay = interval.start
        
        // 获取月份第一天是周几（1是周一，7是周日）
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let adjustedFirstWeekday = (firstWeekday + 5) % 7 + 1
        
        // 获取月份总天数
        let daysCount = calendar.range(of: .day, in: .month, for: targetMonth)!.count
        
        // 计算需要的总格子数（前面的空格 + 实际天数）
        let totalCells = adjustedFirstWeekday - 1 + daysCount
        
        // 计算需要的行数（向上取整）
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
    
    @ViewBuilder
    private func monthView(for targetMonth: Date) -> some View {
        let dates = daysInMonth(for: targetMonth)
        let rowsNeeded = calculateRowsNeeded(for: targetMonth)
        
        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: 0) {
                // 月份标题行
                ForEach(0..<daysInWeek, id: \.self) { index in
                    monthTitleView(at: index, for: targetMonth, dates: dates)
                }
                
                // 日期网格
                ForEach(dates.indices, id: \.self) { index in
                    dayView(for: dates[index])
                }
            }
        }
        .frame(height: CGFloat(rowsNeeded + 1) * cellHeight) // +1 是为了标题行
        .padding(.vertical, 1)
        .id(targetMonth)
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(visibleMonths, id: \.self) { targetMonth in
                        monthView(for: targetMonth)
                            .id(targetMonth)
                            .onAppear {
                                if targetMonth == visibleMonths.last {
                                    loadMoreMonths(direction: .forward)
                                } else if targetMonth == visibleMonths.first {
                                    loadMoreMonths(direction: .backward)
                                }
                            }
                    }
                }
            }
            .onAppear {
                initializeMonths()
                // 确保只在第一次出现时滚动到当前月份
                if !scrolledToInitial {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToMonth(month, proxy: proxy)
                        scrolledToInitial = true
                    }
                }
            }
        }
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
