import SwiftUI

struct SPCalendarView: View {
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @Binding var isShowingDayView: Bool
    @State private var currentMonth: Date
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    private let calendar = Calendar.current
    
    // MARK: - Initialization
    
    init(selectedDate: Binding<Date>, isShowingDayView: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._isShowingDayView = isShowingDayView
        
        // 确保初始月份是当前选择日期所在的月份
        let date = selectedDate.wrappedValue
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        let monthStart = Calendar.current.date(from: components) ?? date
        self._currentMonth = State(initialValue: monthStart)
    }
    
    // MARK: - Helper Methods
    
    private func onMonthAppear(_ month: Date) {
        if !calendar.isDate(month, equalTo: currentMonth, toGranularity: .month) {
            withAnimation {
                currentMonth = month
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 导航栏
                SPCalendarNavigationBar(
                    onDismiss: { dismiss() },
                    isShowingDayView: isShowingDayView,
                    currentMonth: $currentMonth
                )
                
                // 内容视图
                if isShowingDayView {
                    // 日视图
                    SPDayTimelineView(selectedDate: $selectedDate)
                } else {
                    // 月视图 - 使用单个SPMonthCalendarView实例
                    SPMonthCalendarView(month: currentMonth)
                        .onChange(of: currentMonth) { _, newMonth in
                            onMonthAppear(newMonth)
                        }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview

#Preview {
    SPCalendarView(
        selectedDate: .constant(Date()),
        isShowingDayView: .constant(false)
    )
    .environmentObject(ThemeManager.shared)
}
