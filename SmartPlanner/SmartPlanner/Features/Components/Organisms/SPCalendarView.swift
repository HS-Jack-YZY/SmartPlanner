import SwiftUI

struct SPCalendarView: View {
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @Binding var isShowingDayView: Bool
    @State private var currentMonth: Date
    @State private var isEditingDate: Bool = false
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
    
    private func handleDateSelected(_ date: Date) {
        currentMonth = date
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 背景点击区域
            if isEditingDate {
                Color.black.opacity(0.01) // 几乎透明的背景
                    .onTapGesture {
                        isEditingDate = false
                    }
            }
            
            VStack(spacing: 0) {
                // 导航栏
                SPCalendarNavigationBar(
                    currentMonth: currentMonth,
                    isEditing: $isEditingDate,
                    onPreviousMonth: { moveMonth(by: -1) },
                    onNextMonth: { moveMonth(by: 1) },
                    onDateSelected: handleDateSelected
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
        .animation(.easeInOut, value: isEditingDate)
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
