import SwiftUI
import UIKit

struct SPCalendarView: View {
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @State private var currentMonth: Date
    
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
                currentMonth: $currentMonth
            )
            
            // 底部工具栏
            HStack {
                Button(action: scrollToToday) {
                    Text("今天")
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("日历")
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("收件箱")
                        .foregroundColor(.red)
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
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = DateHelper.calendar
        calendarView.locale = .current
        calendarView.fontDesign = .rounded
        calendarView.delegate = context.coordinator
        
        // 配置选择行为
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        calendarView.selectionBehavior = dateSelection
        
        // 设置可见月份
        calendarView.visibleDateComponents = DateHelper.dateComponents(from: currentMonth, components: [.year, .month])
        
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // 更新可见月份
        uiView.visibleDateComponents = DateHelper.dateComponents(from: currentMonth, components: [.year, .month])
        
        // 更新选中日期
        if let selectionBehavior = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            let selectedComponents = DateHelper.dateComponents(from: selectedDate)
            selectionBehavior.setSelected(selectedComponents, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
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
            // 这里可以添加节日、农历等装饰
            if let date = DateHelper.date(from: dateComponents),
               DateHelper.isToday(date) {
                return .default(color: .red)
            }
            return nil
        }
    }
}

// MARK: - Preview

struct SPCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        SPCalendarView(selectedDate: .constant(Date()))
    }
} 