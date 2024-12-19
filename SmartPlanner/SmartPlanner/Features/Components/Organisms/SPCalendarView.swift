import SwiftUI

struct SPCalendarView: View {
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @Binding var isShowingDayView: Bool
    @State private var currentMonth: Date
    @State private var months: [Date] = []
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initialization
    
    init(selectedDate: Binding<Date>, isShowingDayView: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._isShowingDayView = isShowingDayView
        self._currentMonth = State(initialValue: selectedDate.wrappedValue)
    }
    
    // MARK: - Helper Methods
    
    private func generateMonths() {
        let calendar = Calendar.current
        months = (-12...12).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: currentMonth)
        }
    }
    
    private func onMonthAppear(_ month: Date) {
        let calendar = Calendar.current
        if !calendar.isDate(month, equalTo: currentMonth, toGranularity: .month) {
            currentMonth = month
            // 当滚动到边界月份时，重新生成月份数组
            if calendar.dateComponents([.month], from: months.first ?? Date(), to: month).month ?? 0 <= 3 ||
               calendar.dateComponents([.month], from: month, to: months.last ?? Date()).month ?? 0 <= 3 {
                generateMonths()
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 导航栏
                SPCalendarNavigationBar(
                    onDismiss: { dismiss() }
                )
                
                // 内容视图
                if isShowingDayView {
                    // 日视图
                    SPDayTimelineView(selectedDate: $selectedDate)
                } else {
                    // 月视图
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(months, id: \.self) { month in
                                SPMonthCalendarView(month: month)
                                    .id(month)
                                    .onAppear {
                                        onMonthAppear(month)
                                    }
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                generateMonths()
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
