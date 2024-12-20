import SwiftUI

struct SPCalendarNavigationBar: View {
    // MARK: - Properties
    
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    let currentMonth: Date
    
    @EnvironmentObject private var themeManager: ThemeManager
    private let weekdays = Calendar.current.shortWeekdaySymbols.rotateLeft(by: 1) // 从周一开始
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 月份标题和切换按钮行
            HStack {
                Text(formatDate(currentMonth))
                    .font(.title2)
                    .foregroundColor(themeManager.getThemeColor(.primaryText))
                Spacer()
                HStack(spacing: 16) {
                    Button(action: onPreviousMonth) {
                        Image(systemName: "chevron.left")
                            .imageScale(.medium)
                            .foregroundColor(themeManager.getThemeColor(.primaryText))
                    }
                    Button(action: onNextMonth) {
                        Image(systemName: "chevron.right")
                            .imageScale(.medium)
                            .foregroundColor(themeManager.getThemeColor(.primaryText))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            // 星期标题行
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(themeManager.getThemeColor(.secondaryText))
                        .font(.caption)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // 底部分隔线
            Divider()
                .background(themeManager.getThemeColor(.calendarToolbarTint).opacity(0.2))
        }
        .background(themeManager.getThemeColor(.secondaryBackground))
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

struct SPCalendarNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 浅色模式预览
            SPCalendarNavigationBar(
                onPreviousMonth: {},
                onNextMonth: {},
                currentMonth: Date()
            )
            .environmentObject(ThemeManager.shared)
            .previewDisplayName("浅色模式")
            
            // 深色模式预览
            SPCalendarNavigationBar(
                onPreviousMonth: {},
                onNextMonth: {},
                currentMonth: Date()
            )
            .environmentObject(ThemeManager.shared)
            .preferredColorScheme(.dark)
            .previewDisplayName("深色模式")
        }
    }
} 