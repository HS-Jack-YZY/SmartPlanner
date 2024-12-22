import SwiftUI

struct SPNavigationBar: View {
    // MARK: - Properties
    
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    let currentMonth: Date
    let onDateSelected: (Date, Bool) -> Void
    let viewMode: CalendarViewMode
    let onBackToMonth: () -> Void
    
    @Binding var isEditing: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var editingDate: Date
    @State private var monthDragOffset: CGFloat = 0
    @State private var yearDragOffset: CGFloat = 0
    @State private var isDraggingMonth: Bool = false
    @State private var isDraggingYear: Bool = false
    @State private var monthDragVelocity: CGFloat = 0
    @State private var yearDragVelocity: CGFloat = 0
    @State private var lastDragMonthDate: Date = Date()
    @State private var lastDragYearDate: Date = Date()
    @State private var weekDates: [Date] = []
    
    private let weekdays = Calendar.current.veryShortWeekdaySymbols.rotateLeft(by: 1)
    private let calendar = Calendar.current
    private let navigationHeight: CGFloat = 88
    private let itemWidth: CGFloat = UIScreen.main.bounds.width / 5
    private let springStiffness: CGFloat = 180
    private let springDamping: CGFloat = 20
    private let velocityMultiplier: CGFloat = 0.2
    
    // MARK: - Initialization
    
    init(currentMonth: Date, isEditing: Binding<Bool>, viewMode: CalendarViewMode, onPreviousMonth: @escaping () -> Void, onNextMonth: @escaping () -> Void, onDateSelected: @escaping (Date, Bool) -> Void, onBackToMonth: @escaping () -> Void) {
        self.currentMonth = currentMonth
        self._isEditing = isEditing
        self.viewMode = viewMode
        self.onPreviousMonth = onPreviousMonth
        self.onNextMonth = onNextMonth
        self.onDateSelected = onDateSelected
        self.onBackToMonth = onBackToMonth
        self._editingDate = State(initialValue: currentMonth)
        self._lastDragMonthDate = State(initialValue: currentMonth)
        self._lastDragYearDate = State(initialValue: currentMonth)
    }
    
    // MARK: - Helper Methods
    
    private func updateWeekDates() {
        let calendar = Calendar.current
        
        // 获取选中日期是周几（1是周日，2是周一，依此类推）
        let weekday = calendar.component(.weekday, from: currentMonth)
        // 计算到周一的偏移量（如果是周日，需要往前推6天）
        let daysToMonday = weekday == 1 ? -6 : -(weekday - 2)
        
        // 从周一开始生成一周的日期
        weekDates = (0...6).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: daysToMonday + dayOffset, to: currentMonth)
        }
    }
    
    private func formatMonth(_ date: Date, isEditing: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = isEditing ? "MMM" : "MMMM"
        return formatter.string(from: date)
    }
    
    private func formatYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    private func getAdjacentDates(for date: Date, component: Calendar.Component) -> [Date] {
        let values = [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5]
        return values.compactMap { offset in
            calendar.date(byAdding: component, value: offset, to: date)
        }
    }
    
    private func calculateSpringTarget(offset: CGFloat, velocity: CGFloat) -> CGFloat {
        let nearestStop = round(offset / itemWidth) * itemWidth
        let velocityInfluence = velocity * velocityMultiplier
        let targetOffset = nearestStop + velocityInfluence
        return round(targetOffset / itemWidth) * itemWidth
    }
    
    private func handleDragEnd(translation: CGFloat, velocity: CGFloat, isMonth: Bool) {
        let targetOffset = calculateSpringTarget(offset: translation, velocity: velocity)
        let difference = Int(round(targetOffset / itemWidth))
        
        if isMonth {
            if let newDate = calendar.date(byAdding: .month, value: -difference, to: lastDragMonthDate) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)) {
                    editingDate = newDate
                    monthDragOffset = 0
                    isDraggingMonth = false
                    monthDragVelocity = 0
                }
                onDateSelected(newDate, false)
                lastDragMonthDate = newDate
            }
        } else {
            if let newDate = calendar.date(byAdding: .year, value: -difference, to: lastDragYearDate) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)) {
                    editingDate = newDate
                    yearDragOffset = 0
                    isDraggingYear = false
                    yearDragVelocity = 0
                }
                onDateSelected(newDate, false)
                lastDragYearDate = newDate
            }
        }
    }
    
    private func getOffset(for index: Int, dragOffset: CGFloat, isMonth: Bool) -> CGFloat {
        let centerIndex = isMonth ? 5 : 5
        let baseOffset = CGFloat(index - centerIndex) * itemWidth
        return baseOffset + dragOffset
    }
    
    private func getOpacity(for index: Int, dragOffset: CGFloat, isMonth: Bool) -> Double {
        let centerIndex = 5
        let distance = abs(CGFloat(index - centerIndex) + dragOffset / itemWidth)
        return max(0, 1 - distance * 0.25)
    }
    
    private func getScale(for index: Int, dragOffset: CGFloat, isMonth: Bool) -> CGFloat {
        let centerIndex = 5
        let distance = abs(CGFloat(index - centerIndex) + dragOffset / itemWidth)
        return max(0.8, 1 - distance * 0.1)
    }
    
    private func getFontSize(for index: Int, dragOffset: CGFloat, isMonth: Bool) -> CGFloat {
        let centerIndex = 5
        let distance = abs(CGFloat(index - centerIndex) + dragOffset / itemWidth)
        let maxSize: CGFloat = 22
        let minSize: CGFloat = 13
        return max(minSize, maxSize - distance * 2.5)
    }
    
    // MARK: - Views
    
    private var dayView: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            HStack {
                // 返回按钮
                Button(action: onBackToMonth) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .foregroundColor(themeManager.getThemeColor(.primaryText))
                }
                .padding(.leading, 16)
                
                Spacer()
            }
            .frame(height: 28)
            
            // 日期滚动视图
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(weekDates, id: \.self) { date in
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: currentMonth),
                            themeManager: themeManager
                        )
                        .onTapGesture {
                            onDateSelected(date, false)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(height: navigationHeight)
        .onAppear {
            updateWeekDates()
        }
    }
    
    private var normalView: some View {
        VStack(spacing: 0) {
            // 月份标题和切换按钮行
            HStack {
                // 月份和年份选择器按钮
                Button(action: { isEditing = true }) {
                    HStack(spacing: 4) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(formatMonth(currentMonth))
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.getThemeColor(.primaryText))
                            Text(formatYear(currentMonth))
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(themeManager.getThemeColor(.secondaryText))
                        }
                        
                        Image(systemName: "chevron.compact.right")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.getThemeColor(.secondaryText))
                            .padding(.leading, 1)
                            .opacity(0.6)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(themeManager.getThemeColor(.primaryText).opacity(0.1), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(themeManager.getThemeColor(.primaryText).opacity(0.03))
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
                
                Spacer()
                
                // 切换按钮
                HStack(spacing: 16) {
                    Button(action: onPreviousMonth) {
                        Image(systemName: "chevron.left")
                            .imageScale(.medium)
                            .foregroundColor(themeManager.getThemeColor(.primaryText))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onNextMonth) {
                        Image(systemName: "chevron.right")
                            .imageScale(.medium)
                            .foregroundColor(themeManager.getThemeColor(.primaryText))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // 星期标题行
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(themeManager.getThemeColor(.secondaryText))
                        .font(.caption2)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 6)
        }
        .frame(height: navigationHeight)
    }
    
    private var editingView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // 月份选择器
            ZStack {
                // 添加一个透明的背景视图来扩大可点击区域
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: 44)
                
                ForEach(Array(getAdjacentDates(for: editingDate, component: .month).enumerated()), id: \.element) { index, date in
                    Text(formatMonth(date, isEditing: true))
                        .font(.system(size: getFontSize(for: index, dragOffset: monthDragOffset, isMonth: true), design: .rounded))
                        .fontWeight(index == 5 ? .semibold : .medium)
                        .foregroundColor(date == editingDate && !isDraggingMonth ?
                            themeManager.getThemeColor(.primaryText) :
                            themeManager.getThemeColor(.secondaryText))
                        .frame(width: itemWidth)
                        .offset(x: getOffset(for: index, dragOffset: monthDragOffset, isMonth: true))
                        .opacity(getOpacity(for: index, dragOffset: monthDragOffset, isMonth: true))
                        .scaleEffect(getScale(for: index, dragOffset: monthDragOffset, isMonth: true))
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                editingDate = date
                                onDateSelected(date, false)
                                lastDragMonthDate = date
                                monthDragOffset = 0
                                isDraggingMonth = false
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle()) // 确保整个区域都可以响应手势
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        isDraggingMonth = true
                        let translation = gesture.translation.width
                        let velocity = gesture.velocity.width
                        monthDragOffset = translation
                        monthDragVelocity = velocity
                    }
                    .onEnded { gesture in
                        handleDragEnd(
                            translation: gesture.translation.width,
                            velocity: gesture.velocity.width,
                            isMonth: true
                        )
                    }
            )
            
            Spacer()
            
            // 年份选择器
            ZStack {
                // 添加一个透明的背景视图来扩大可点击区域
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: 44)
                
                ForEach(Array(getAdjacentDates(for: editingDate, component: .year).enumerated()), id: \.element) { index, date in
                    Text(formatYear(date))
                        .font(.system(size: getFontSize(for: index, dragOffset: yearDragOffset, isMonth: false), design: .rounded))
                        .fontWeight(index == 5 ? .semibold : .medium)
                        .foregroundColor(date == editingDate && !isDraggingYear ?
                            themeManager.getThemeColor(.primaryText) :
                            themeManager.getThemeColor(.secondaryText))
                        .frame(width: itemWidth)
                        .offset(x: getOffset(for: index, dragOffset: yearDragOffset, isMonth: false))
                        .opacity(getOpacity(for: index, dragOffset: yearDragOffset, isMonth: false))
                        .scaleEffect(getScale(for: index, dragOffset: yearDragOffset, isMonth: false))
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                editingDate = date
                                onDateSelected(date, false)
                                lastDragYearDate = date
                                yearDragOffset = 0
                                isDraggingYear = false
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle()) // 确保整个区域都可以响应手势
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        isDraggingYear = true
                        let translation = gesture.translation.width
                        let velocity = gesture.velocity.width
                        yearDragOffset = translation
                        yearDragVelocity = velocity
                    }
                    .onEnded { gesture in
                        handleDragEnd(
                            translation: gesture.translation.width,
                            velocity: gesture.velocity.width,
                            isMonth: false
                        )
                    }
            )
            
            Spacer()
        }
        .frame(height: navigationHeight)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            if viewMode == .day {
                dayView
            } else if isEditing {
                editingView
            } else {
                normalView
            }
            
            // 底部分隔线
            Divider()
                .background(themeManager.getThemeColor(.secondaryText).opacity(0.2))
        }
        .background(themeManager.getThemeColor(.secondaryBackground))
        .animation(.easeInOut, value: isEditing)
        .onChange(of: currentMonth) { newValue in
            editingDate = newValue
            lastDragMonthDate = newValue
            lastDragYearDate = newValue
            if viewMode == .day {
                updateWeekDates()
            }
        }
    }
}

// MARK: - Supporting Views

private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let themeManager: ThemeManager
    private let calendar = Calendar.current
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var weekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .red
        } else {
            return themeManager.getThemeColor(.primaryText)
        }
    }
    
    private var backgroundFill: Color {
        if isToday && isSelected {
            return .red
        } else if isSelected {
            return themeManager.getThemeColor(.primaryText)
        } else {
            return .clear
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // 星期标题
            Text(weekday)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(themeManager.getThemeColor(.secondaryText))
            
            // 日期数字（带圆圈背景）
            Text(dayNumber)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(textColor)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(backgroundFill)
                )
        }
        .frame(width: 44, height: 64)
    }
}

// MARK: - Enums

enum CalendarViewMode {
    case day
    case week
    case month
}

// MARK: - Helper Methods

extension Array {
    func rotateLeft(by: Int) -> [Element] {
        guard count > 0, by > 0 else { return self }
        let by = by % count
        return Array(self[by...] + self[..<by])
    }
}

// MARK: - Preview

#Preview("浅色模式") {
    // 浅色模式预览
    SPNavigationBar(
        currentMonth: Date(),
        isEditing: .constant(false),
        viewMode: .month,
        onPreviousMonth: {},
        onNextMonth: {},
        onDateSelected: { _, _ in },
        onBackToMonth: {}
    )
    .environmentObject(ThemeManager.shared)
}

#Preview("深色模式") {
    // 深色模式预览
    SPNavigationBar(
        currentMonth: Date(),
        isEditing: .constant(false),
        viewMode: .month,
        onPreviousMonth: {},
        onNextMonth: {},
        onDateSelected: { _, _ in },
        onBackToMonth: {}
    )
    .environmentObject(ThemeManager.shared)
    .preferredColorScheme(.dark)
} 
