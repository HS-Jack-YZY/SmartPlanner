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
                if isShowingDayView {
                    // 日视图
                    SPDayTimelineView(selectedDate: $selectedDate)
                } else {
                    // 月视图
                    SPMonthCalendarView(
                        selectedDate: $selectedDate,
                        currentMonth: $currentMonth
                    )
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // 左侧返回按钮和年份
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
                        }
                        Text("\(DateHelper.year(from: currentMonth))年")
                            .font(FontTheme.title2)
                            .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
                    }
                }
                
                // 中间月份标题
                ToolbarItem(placement: .principal) {
                    Text(DateHelper.chineseMonth(from: currentMonth))
                        .font(FontTheme.largeTitle)
                        .foregroundColor(.primary)
                }
                
                // 右侧按钮组
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 20) {
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
                        }
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
                        }
                    }
                }
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