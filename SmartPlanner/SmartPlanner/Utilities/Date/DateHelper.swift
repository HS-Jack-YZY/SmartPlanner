import Foundation

enum DateHelper {
    // MARK: - Properties
    
    /// 私有日历实例
    private static var _calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.current
        return calendar
    }()
    
    /// 公开的日历实例
    static var calendar: Calendar {
        get { _calendar }
        set { _calendar = newValue }
    }
    
    // MARK: - Public Methods
    
    /// 获取年份
    static func year(from date: Date) -> Int {
        calendar.component(.year, from: date)
    }
    
    /// 获取本地化月份
    static func chineseMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    /// 获取月份简写（如：Jan）
    static func formatShortMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US") // 使用英文简写
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    /// 格式化日期标题（如：周三 12月18日）
    static func formatDayHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale
        formatter.dateFormat = "EEEE MMM d日"
        return formatter.string(from: date)
    }
    
    /// 格式化星期几（如：周三）
    static func formatWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    /// 格式化当前时间（如：17:11）
    static func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
    
    /// 检查给定小时是否是当前小时
    static func isCurrentHour(_ hour: Int, for date: Date) -> Bool {
        guard calendar.isDateInToday(date) else { return false }
        let currentHour = calendar.component(.hour, from: Date())
        return hour == currentHour
    }
    
    /// 计算当前分钟在小时内的偏移量
    static func currentMinuteOffset(hourHeight: CGFloat) -> CGFloat {
        let minute = calendar.component(.minute, from: Date())
        return (CGFloat(minute) / 60.0) * hourHeight
    }
    
    /// 获取日期组件
    static func dateComponents(from date: Date, components: Set<Calendar.Component> = [.era, .year, .month, .day]) -> DateComponents {
        calendar.dateComponents(components, from: date)
    }
    
    /// 从日期组件创建日期
    static func date(from components: DateComponents) -> Date? {
        calendar.date(from: components)
    }
    
    /// 判断是否是今天
    static func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    /// 判断是否是周末
    static func isWeekend(_ date: Date) -> Bool {
        calendar.isDateInWeekend(date)
    }
} 