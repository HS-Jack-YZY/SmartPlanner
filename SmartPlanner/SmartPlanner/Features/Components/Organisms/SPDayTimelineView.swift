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
            SPTimelineHeaderView(
                dates: displayDates,
                timeColumnWidth: timeColumnWidth,
                dayColumnWidth: dayColumnWidth
            )
            
            // 可滚动的时间线部分
            SPTimelineContentView(
                dates: displayDates,
                hourHeight: hourHeight,
                timelineStartHour: timelineStartHour,
                timelineEndHour: timelineEndHour,
                timeColumnWidth: timeColumnWidth,
                dayColumnWidth: dayColumnWidth
            )
        }
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
