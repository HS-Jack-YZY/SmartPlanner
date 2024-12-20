import SwiftUI

struct SPCalendarView: View {
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @Binding var isShowingDayView: Bool
    @State private var currentMonth: Date
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Initialization
    
    init(selectedDate: Binding<Date>, isShowingDayView: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._isShowingDayView = isShowingDayView
        self._currentMonth = State(initialValue: selectedDate.wrappedValue)
    }
    
    // MARK: - Helper Methods
    
    private func moveMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 导航栏
            SPCalendarNavigationBar(
                onPreviousMonth: { moveMonth(by: -1) },
                onNextMonth: { moveMonth(by: 1) },
                currentMonth: currentMonth
            )
            
            // 内容视图
            if isShowingDayView {
                // 日视图
                SPDayTimelineView(selectedDate: $selectedDate)
            } else {
                // 月视图
                SPMonthCalendarView(month: currentMonth)
            }
        }
    }
}

// MARK: - Preview

struct SPCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        SPCalendarView(
            selectedDate: .constant(Date()),
            isShowingDayView: .constant(false)
        )
        .environmentObject(ThemeManager.shared)
    }
}
