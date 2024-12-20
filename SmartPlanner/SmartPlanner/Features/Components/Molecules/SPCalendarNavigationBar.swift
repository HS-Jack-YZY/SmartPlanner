import SwiftUI

struct SPCalendarNavigationBar: View {
    // MARK: - Properties
    
    @Binding var currentMonth: Date
    let isShowingDayView: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    
    private let calendar = Calendar.current
    private let weekdays = Calendar.current.shortWeekdaySymbols.rotateLeft(by: 1) // 从周一开始
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 导航栏内容
            HStack {
                // 当前年月显示
                Text(monthYearString(from: currentMonth))
                    .foregroundColor(themeManager.getThemeColor(.primaryText))
                    .font(.headline)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
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
    }
    
    // MARK: - Views
    
    private var weekdayHeader: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .foregroundColor(themeManager.getThemeColor(.secondaryText))
                        .frame(width: (geometry.size.width - 32) / CGFloat(weekdays.count))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
        }
        .frame(height: 20)
    }
    
    // MARK: - Helper Methods
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
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

#Preview("月视图") {
    SPCalendarNavigationBar(
        currentMonth: .constant(Date()),
        isShowingDayView: false
    )
    .environmentObject(ThemeManager.shared)
}

#Preview("日视图") {
    SPCalendarNavigationBar(
        currentMonth: .constant(Date()),
        isShowingDayView: true
    )
    .environmentObject(ThemeManager.shared)
} 
