import SwiftUI

struct SPDayTimelineView: View {
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @EnvironmentObject private var themeManager: ThemeManager
    
    private let hourHeight: CGFloat = 60
    private let timelineStartHour: Int = 0
    private let timelineEndHour: Int = 24
    private let currentTimeIndicatorWidth: CGFloat = 50
    
    // MARK: - Initialization
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 日期标题
                dayHeader
                
                // 时间轴
                timelineContent
            }
        }
    }
    
    // MARK: - Views
    
    private var dayHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(DateHelper.formatDayHeader(selectedDate))
                .font(FontTheme.title3)
                .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
                .padding(.horizontal)
                .padding(.top, 8)
            
            Divider()
        }
    }
    
    private var timelineContent: some View {
        VStack(spacing: 0) {
            ForEach(timelineStartHour..<timelineEndHour, id: \.self) { hour in
                timeSlot(for: hour)
            }
        }
    }
    
    private func timeSlot(for hour: Int) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                // 时间标签
                Text(String(format: "%02d:00", hour))
                    .font(FontTheme.footnote)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .center)
                
                // 分隔线
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 0.5)
                    .offset(y: 8)
            }
            
            // 当前时间指示器
            if DateHelper.isCurrentHour(hour, for: selectedDate) {
                currentTimeIndicator
            }
            
            Spacer()
                .frame(height: hourHeight)
        }
    }
    
    private var currentTimeIndicator: some View {
        HStack(spacing: 0) {
            // 时间文本
            Text(DateHelper.formatCurrentTime())
                .font(FontTheme.footnote)
                .foregroundColor(themeManager.getThemeColor(.calendarTodayText))
                .frame(width: currentTimeIndicatorWidth)
            
            // 指示线
            Rectangle()
                .fill(themeManager.getThemeColor(.calendarTodayText))
                .frame(height: 1)
        }
        .padding(.top, DateHelper.currentMinuteOffset(hourHeight: hourHeight))
    }
} 

// MARK: - Preview
struct SPDayTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 今天的预览
            SPDayTimelineView(selectedDate: .constant(Date()))
                .environmentObject(ThemeManager.shared)
                .previewDisplayName("今天")
            
            // 明天的预览
            SPDayTimelineView(selectedDate: .constant(Calendar.current.date(byAdding: .day, value: 1, to: Date())!))
                .environmentObject(ThemeManager.shared)
                .preferredColorScheme(.dark)
                .previewDisplayName("明天（深色模式）")
            
            // 昨天的预览
            SPDayTimelineView(selectedDate: .constant(Calendar.current.date(byAdding: .day, value: -1, to: Date())!))
                .environmentObject(ThemeManager.shared)
                .previewDisplayName("昨天")
        }
    }
} 