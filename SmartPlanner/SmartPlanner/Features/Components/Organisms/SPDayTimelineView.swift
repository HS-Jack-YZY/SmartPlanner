import SwiftUI

struct SPDayTimelineView: View {
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @EnvironmentObject private var themeManager: ThemeManager
    
    private let hourHeight: CGFloat = 60
    private let timelineStartHour: Int = 0
    private let timelineEndHour: Int = 24
    private let timeColumnWidth: CGFloat = 50
    private let dayColumnWidth: CGFloat = (UIScreen.main.bounds.width - 50) / 4 // 4天视图的列宽
    
    // MARK: - Computed Properties
    
    private var displayDates: [Date] {
        (0...3).map { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) ?? selectedDate
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 固定的日期标题行
            HStack(spacing: 0) {
                // 时间列标题占位
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: timeColumnWidth, height: 44)
                
                // 日期标题行
                HStack(spacing: 0) {
                    ForEach(displayDates, id: \.self) { date in
                        dayHeader(for: date)
                            .frame(height: 44)
                    }
                }
            }
            .background(themeManager.getThemeColor(.secondaryBackground))
            
            // 可滚动的时间线部分
            ScrollView(.vertical, showsIndicators: false) {
                HStack(spacing: 0) {
                    // 时间列
                    timeColumn
                    
                    // 4天的内容列
                    HStack(spacing: 0) {
                        ForEach(displayDates, id: \.self) { date in
                            dayContentColumn(for: date)
                        }
                    }
                }
                .frame(minHeight: CGFloat(timelineEndHour - timelineStartHour) * hourHeight)
            }
        }
    }
    
    // MARK: - Views
    
    private var timeColumn: some View {
        VStack(spacing: 0) {
            // 时间标签
            ForEach(timelineStartHour..<timelineEndHour, id: \.self) { hour in
                Text(String(format: "%02d:00", hour))
                    .font(.footnote)
                    .foregroundColor(themeManager.getThemeColor(.secondaryText))
                    .frame(width: timeColumnWidth, height: hourHeight, alignment: .center)
            }
        }
    }
    
    private func dayContentColumn(for date: Date) -> some View {
        VStack(spacing: 0) {
            // 时间格子
            ForEach(timelineStartHour..<timelineEndHour, id: \.self) { hour in
                timeSlot(for: date, hour: hour)
            }
        }
        .frame(width: dayColumnWidth)
    }
    
    private func dayHeader(for date: Date) -> some View {
        VStack(alignment: .center, spacing: 2) {
            // 星期几
            Text(DateHelper.formatWeekday(date))
                .font(.system(size: 13))
                .fontWeight(.medium)
                .foregroundColor(themeManager.getThemeColor(.secondaryText))
            
            // 月份和日期
            HStack(spacing: 1) {
                Text(DateHelper.formatShortMonth(date))
                    .font(.system(size: 13))
                    .fontWeight(.regular)
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 15))
                    .fontWeight(.medium)
            }
            .foregroundColor(Calendar.current.isDateInToday(date) ?
                themeManager.getThemeColor(.calendarTodayText) :
                themeManager.getThemeColor(.primaryText))
        }
        .frame(width: dayColumnWidth)
        .padding(.vertical, 4)
        .background(themeManager.getThemeColor(.secondaryBackground))
    }
    
    private func timeSlot(for date: Date, hour: Int) -> some View {
        ZStack(alignment: .top) {
            // 时间格子背景
            Rectangle()
                .fill(themeManager.getThemeColor(.secondaryBackground))
                .border(Color.gray.opacity(0.2), width: 0.5)
            
            // 当前时间指示器
            if Calendar.current.isDateInToday(date) && DateHelper.isCurrentHour(hour, for: date) {
                currentTimeIndicator
                    .padding(.top, DateHelper.currentMinuteOffset(hourHeight: hourHeight))
            }
        }
        .frame(height: hourHeight)
    }
    
    private var currentTimeIndicator: some View {
        Rectangle()
            .fill(themeManager.getThemeColor(.calendarTodayText))
            .frame(height: 2)
            .shadow(color: themeManager.getThemeColor(.calendarTodayText).opacity(0.3),
                   radius: 2, y: 1)
    }
}

// MARK: - Preview

#Preview("今天") {
    SPDayTimelineView(selectedDate: .constant(Date()))
        .environmentObject(ThemeManager.shared)
}

#Preview("深色模式") {
    SPDayTimelineView(selectedDate: .constant(Date()))
        .environmentObject(ThemeManager.shared)
        .preferredColorScheme(.dark)
} 
