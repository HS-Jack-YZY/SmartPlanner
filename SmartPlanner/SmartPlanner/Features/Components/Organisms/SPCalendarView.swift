import SwiftUI
import UIKit

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
                    CalendarViewRepresentable(
                        selectedDate: $selectedDate,
                        currentMonth: $currentMonth,
                        themeManager: themeManager
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

// MARK: - CalendarViewRepresentable

private struct CalendarViewRepresentable: UIViewRepresentable {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    let themeManager: ThemeManager
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = DateHelper.calendar
        calendarView.locale = .current
        calendarView.fontDesign = .rounded
        calendarView.delegate = context.coordinator
        
        // 配置选择行为
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        dateSelection.selectedDate = DateHelper.dateComponents(from: selectedDate)
        calendarView.selectionBehavior = dateSelection
        
        // 设置可见月份
        calendarView.visibleDateComponents = DateHelper.dateComponents(from: currentMonth, components: [.year, .month])
        
        // 配置外观
        configureAppearance(calendarView)
        
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // 更新可见月份
        uiView.visibleDateComponents = DateHelper.dateComponents(from: currentMonth, components: [.year, .month])
        
        // 更新选中日期
        if let selectionBehavior = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            let selectedComponents = DateHelper.dateComponents(from: selectedDate)
            selectionBehavior.selectedDate = selectedComponents
        }
        
        // 更新外观
        configureAppearance(uiView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // MARK: - Private Methods
    
    private func configureAppearance(_ calendarView: UICalendarView) {
        // 设置基本颜色
        calendarView.tintColor = UIColor(themeManager.getThemeColor(.calendarSelectedBackground))
        calendarView.backgroundColor = UIColor(themeManager.getThemeColor(.background))
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarViewRepresentable
        
        init(parent: CalendarViewRepresentable) {
            self.parent = parent
        }
        
        // 日期选择回调
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            if let dateComponents = dateComponents,
               let selectedDate = DateHelper.date(from: dateComponents) {
                parent.selectedDate = selectedDate
                parent.currentMonth = selectedDate
            }
        }
        
        // 装饰视图
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            if let date = DateHelper.date(from: dateComponents) {
                // 今天日期
                if DateHelper.isToday(date) {
                    return .default(color: UIColor(parent.themeManager.getThemeColor(.calendarTodayText)))
                }
                
                // 周末日期
                if let weekday = dateComponents.weekday, weekday == 1 || weekday == 7 {
                    return .default(color: UIColor(parent.themeManager.getThemeColor(.calendarWeekendText)))
                }
                
                // 非当前月份
                if let month = dateComponents.month,
                   let currentMonth = DateHelper.calendar.dateComponents([.month], from: parent.currentMonth).month,
                   month != currentMonth {
                    return .default(color: UIColor(parent.themeManager.getThemeColor(.calendarOutOfMonthText)))
                }
            }
            return nil
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