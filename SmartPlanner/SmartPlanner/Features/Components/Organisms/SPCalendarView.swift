import SwiftUI

struct SPCalendarView: View {
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @State private var currentMonth: Date
    @State private var months: [Date] = []
    @State private var scrollOffset: CGFloat = 0
    
    // MARK: - Initialization
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._currentMonth = State(initialValue: selectedDate.wrappedValue)
        self._months = State(initialValue: [])
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 日历头部
            SPCalendarHeaderView(
                currentDate: currentMonth,
                onPreviousMonth: previousMonth,
                onNextMonth: nextMonth
            )
            
            // 星期标题行
            HStack(spacing: 0) {
                ForEach(DateHelper.weekdaySymbols(), id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
            
            Divider()
            
            // 滚动视图
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0, pinnedViews: []) {
                    ForEach(months, id: \.self) { month in
                        MonthView(
                            month: month,
                            selectedDate: $selectedDate,
                            currentMonth: $currentMonth
                        )
                        .background(GeometryReader { proxy in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: proxy.frame(in: .named("scroll")).minY
                            )
                        })
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            
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
        .onAppear {
            setupMonths()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupMonths() {
        let numberOfMonths = 12
        var newMonths: [Date] = []
        
        for i in -numberOfMonths...numberOfMonths {
            if let date = DateHelper.calendar.date(byAdding: .month, value: i, to: currentMonth) {
                newMonths.append(date)
            }
        }
        
        months = newMonths.sorted()
    }
    
    private func previousMonth() {
        withAnimation {
            if let date = DateHelper.calendar.date(byAdding: .month, value: -1, to: currentMonth) {
                currentMonth = date
            }
        }
    }
    
    private func nextMonth() {
        withAnimation {
            if let date = DateHelper.calendar.date(byAdding: .month, value: 1, to: currentMonth) {
                currentMonth = date
            }
        }
    }
    
    private func scrollToToday() {
        withAnimation {
            currentMonth = Date()
            selectedDate = Date()
        }
    }
}

// MARK: - MonthView

private struct MonthView: View {
    let month: Date
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    
    var body: some View {
        VStack(spacing: 0) {
            // 日期网格
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                spacing: 0
            ) {
                let daysWithOffset = DateHelper.getDaysInMonth(for: month)
                let offset = daysWithOffset.first?.offset ?? 0
                
                // 添加空白占位
                ForEach(0..<offset, id: \.self) { _ in
                    Color.clear
                        .frame(height: 60)
                }
                
                // 添加日期
                ForEach(daysWithOffset, id: \.date) { dayInfo in
                    if dayInfo === daysWithOffset.first {
                        // 第一天，显示月份标题
                        VStack(spacing: 4) {
                            Text(DateHelper.monthTitle(for: month))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                                .offset(y: -30)
                            
                            SPCalendarDayView(
                                date: dayInfo.date,
                                isSelected: DateHelper.calendar.isDate(dayInfo.date, inSameDayAs: selectedDate),
                                isToday: DateHelper.isToday(dayInfo.date),
                                isInCurrentMonth: true
                            )
                        }
                        .onTapGesture {
                            withAnimation {
                                selectedDate = dayInfo.date
                                currentMonth = month
                            }
                        }
                    } else {
                        SPCalendarDayView(
                            date: dayInfo.date,
                            isSelected: DateHelper.calendar.isDate(dayInfo.date, inSameDayAs: selectedDate),
                            isToday: DateHelper.isToday(dayInfo.date),
                            isInCurrentMonth: true
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedDate = dayInfo.date
                                currentMonth = month
                            }
                        }
                    }
                }
            }
            
            Divider()
                .padding(.vertical, 20)
        }
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - ScrollOffsetPreferenceKey

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

struct SPCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        SPCalendarView(selectedDate: .constant(Date()))
    }
} 