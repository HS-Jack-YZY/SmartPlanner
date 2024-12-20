import SwiftUI

struct SPCalendarView: View {
    // MARK: - Properties
    
    @State private var currentMonth = Date()
    @State private var isShowingDayView = false
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 导航栏
            SPCalendarNavigationBar(
                currentMonth: $currentMonth,
                isShowingDayView: isShowingDayView
            )
            
            // 内容视图
            if isShowingDayView {
                // TODO: 实现日视图
                Text("日视图")
            } else {
                // 月历视图
                SPScrollableMonthCalendarView(currentMonth: $currentMonth)
            }
        }
        .background(themeManager.getThemeColor(.background))
    }
}

// MARK: - Preview

#Preview("月视图") {
    SPCalendarView()
        .environmentObject(ThemeManager.shared)
}

#Preview("日视图") {
    SPCalendarView()
        .environmentObject(ThemeManager.shared)
        .preferredColorScheme(.dark)
}
