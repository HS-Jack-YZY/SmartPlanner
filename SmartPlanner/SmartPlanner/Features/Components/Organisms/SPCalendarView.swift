import SwiftUI
import UIKit

struct SPCalendarView: View {
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @State private var currentMonth: Date
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Initialization
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._currentMonth = State(initialValue: selectedDate.wrappedValue)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarViewRepresentable(
                selectedDate: $selectedDate,
                currentMonth: $currentMonth,
                themeManager: themeManager
            )
            
            // 底部工具栏
            HStack {
                Button(action: scrollToToday) {
                    Text("今天")
                        .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("日历")
                        .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("收件箱")
                        .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
                }
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 10)
        }
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