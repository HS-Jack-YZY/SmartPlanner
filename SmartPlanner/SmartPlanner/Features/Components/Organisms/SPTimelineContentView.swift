import SwiftUI

struct SPTimelineContentView: View {
    // MARK: - Properties
    
    let dates: [Date]
    let hourHeight: CGFloat
    let timelineStartHour: Int
    let timelineEndHour: Int
    let timeColumnWidth: CGFloat
    let dayColumnWidth: CGFloat
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            HStack(spacing: 0) {
                timelineColumn
                contentColumns
            }
            .frame(minHeight: CGFloat(timelineEndHour - timelineStartHour) * hourHeight)
        }
    }
    
    // MARK: - Private Views
    
    private var timelineColumn: some View {
        VStack(spacing: 0) {
            ForEach(timelineStartHour..<timelineEndHour, id: \.self) { hour in
                TimelineHourCell(hour: hour, themeManager: themeManager)
                    .frame(width: timeColumnWidth, height: hourHeight)
            }
        }
        .overlay(
            Rectangle()
                .fill(themeManager.getThemeColor(.secondaryText).opacity(0.2))
                .frame(width: 0.5),
            alignment: .trailing
        )
    }
    
    private var contentColumns: some View {
        HStack(spacing: 0) {
            ForEach(dates, id: \.self) { date in
                TimelineContentColumn(
                    date: date,
                    hourHeight: hourHeight,
                    timelineStartHour: timelineStartHour,
                    timelineEndHour: timelineEndHour,
                    themeManager: themeManager
                )
                .frame(width: dayColumnWidth)
                .overlay(
                    Rectangle()
                        .fill(themeManager.getThemeColor(.secondaryText).opacity(0.2))
                        .frame(width: 0.5),
                    alignment: .trailing
                )
            }
        }
    }
}

// MARK: - Supporting Views

private struct TimelineHourCell: View {
    let hour: Int
    let themeManager: ThemeManager
    
    var body: some View {
        ZStack(alignment: .top) {
            Text(String(format: "%02d:00", hour))
                .font(.system(size: 13))
                .foregroundColor(themeManager.getThemeColor(.secondaryText))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 8)
                .offset(y: -8)
            
            Rectangle()
                .fill(themeManager.getThemeColor(.secondaryText).opacity(0.2))
                .frame(height: 0.5)
        }
    }
}

private struct TimelineContentColumn: View {
    let date: Date
    let hourHeight: CGFloat
    let timelineStartHour: Int
    let timelineEndHour: Int
    let themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(timelineStartHour..<timelineEndHour, id: \.self) { hour in
                TimelineHourSlot(
                    date: date,
                    hour: hour,
                    hourHeight: hourHeight,
                    themeManager: themeManager
                )
                .frame(height: hourHeight)
            }
        }
    }
}

private struct TimelineHourSlot: View {
    let date: Date
    let hour: Int
    let hourHeight: CGFloat
    let themeManager: ThemeManager
    
    private var isCurrentHour: Bool {
        Calendar.current.isDateInToday(date) && DateHelper.isCurrentHour(hour, for: date)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(themeManager.getThemeColor(.background))
                .overlay(
                    Rectangle()
                        .fill(themeManager.getThemeColor(.secondaryText).opacity(0.2))
                        .frame(height: 0.5),
                    alignment: .top
                )
            
            if isCurrentHour {
                Rectangle()
                    .fill(themeManager.getThemeColor(.calendarTodayText))
                    .frame(height: 2)
                    .shadow(
                        color: themeManager.getThemeColor(.calendarTodayText).opacity(0.3),
                        radius: 2,
                        y: 1
                    )
                    .padding(.top, DateHelper.currentMinuteOffset(hourHeight: hourHeight))
            }
        }
    }
}

// MARK: - Preview

#Preview("Timeline Content") {
    SPTimelineContentView(
        dates: [Date(), Date().addingTimeInterval(86400)],
        hourHeight: 60,
        timelineStartHour: 0,
        timelineEndHour: 24,
        timeColumnWidth: 50,
        dayColumnWidth: (UIScreen.main.bounds.width - 50) / 4
    )
    .environmentObject(ThemeManager.shared)
} 