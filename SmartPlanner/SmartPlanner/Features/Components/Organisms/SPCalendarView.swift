import SwiftUI

struct SPCalendarView: View {
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @Binding var isShowingDayView: Bool
    @State private var currentMonth: Date
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initialization
    
    init(selectedDate: Binding<Date>, isShowingDayView: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._isShowingDayView = isShowingDayView
        self._currentMonth = State(initialValue: selectedDate.wrappedValue)
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
                    SPMonthCalendarView(month: currentMonth)
                }
            }
            .navigationBarHidden(true)
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
