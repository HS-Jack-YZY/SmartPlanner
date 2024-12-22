import SwiftUI

struct SPTimelineHeaderView: View {
    // MARK: - Properties
    
    let dates: [Date]
    let timeColumnWidth: CGFloat
    let dayColumnWidth: CGFloat
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 0) {
            // 时间列标题占位
            Rectangle()
                .fill(Color.clear)
                .frame(width: timeColumnWidth, height: 44)
            
            // 日期标题行
            HStack(spacing: 0) {
                ForEach(dates, id: \.self) { date in
                    dayHeader(for: date)
                        .frame(height: 44)
                        .background(themeManager.getThemeColor(.background))
                        .overlay(
                            Rectangle()
                                .fill(themeManager.getThemeColor(.secondaryText).opacity(0.2))
                                .frame(width: 0.5),
                            alignment: .trailing
                        )
                }
            }
        }
        .background(themeManager.getThemeColor(.background))
        .overlay(
            Rectangle()
                .fill(themeManager.getThemeColor(.secondaryText).opacity(0.2))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
    
    // MARK: - Private Views
    
    private func dayHeader(for date: Date) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(DateHelper.formatWeekday(date))
                .font(.system(size: 13))
                .fontWeight(.medium)
                .foregroundColor(themeManager.getThemeColor(.secondaryText))
            
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
        .background(themeManager.getThemeColor(.background))
    }
}

// MARK: - Preview

#Preview("Timeline Header") {
    SPTimelineHeaderView(
        dates: [Date(), Date().addingTimeInterval(86400)],
        timeColumnWidth: 50,
        dayColumnWidth: (UIScreen.main.bounds.width - 50) / 4
    )
    .environmentObject(ThemeManager.shared)
} 