import SwiftUI

struct SPCalendarView: View {
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @State private var currentMonth: Date
    @State private var isShowingDayView: Bool = false
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initialization
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
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
                
                Spacer(minLength: 0)
                
                // 底部工具栏
                bottomToolbar
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 16)
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
    
    // MARK: - Views
    
    private var bottomToolbar: some View {
        HStack(spacing: 30) {
            Button(action: scrollToToday) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.circle.fill")
                    Text("今天")
                }
                .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
            }
            
            Divider()
                .frame(height: 20)
                .background(Color.gray.opacity(0.3))
            
            Button(action: { isShowingDayView.toggle() }) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text(isShowingDayView ? "月" : "日")
                }
                .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
            }
            
            Divider()
                .frame(height: 20)
                .background(Color.gray.opacity(0.3))
            
            Button(action: {}) {
                HStack(spacing: 4) {
                    Image(systemName: "tray")
                    Text("收件箱")
                }
                .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 0)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    // MARK: - Private Methods
    
    private func scrollToToday() {
        withAnimation {
            currentMonth = Date()
            selectedDate = Date()
        }
    }
}

// MARK: - Preview

struct SPCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        SPCalendarView(selectedDate: .constant(Date()))
            .environmentObject(ThemeManager.shared)
    }
}