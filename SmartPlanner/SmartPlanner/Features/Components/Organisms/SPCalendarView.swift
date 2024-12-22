import SwiftUI

struct SPCalendarView: View {
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @Binding var isShowingDayView: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Body
    
    var body: some View {
        // 内容视图
        VStack {
            if isShowingDayView {
                // 日视图
                    SPDayTimelineView(selectedDate: $selectedDate)
            } else {
                // 月视图
                ScrollView{
                    SPMonthCalendarView(
                        month: selectedDate,
                        onDateSelected: handleDateSelected
                    )}
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    // MARK: - Private Methods
    
    private func handleDateSelected(_ date: Date) {
        selectedDate = date
        withAnimation(.easeInOut(duration: 0.3)) {
            isShowingDayView = true
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
