import Foundation

enum DateHelper {
    /// 共享日历实例
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "zh_CN")
        return calendar
    }()
    
    /// 获取年份
    static func year(from date: Date) -> Int {
        calendar.component(.year, from: date)
    }
    
    /// 获取中文月份
    static func chineseMonth(from date: Date) -> String {
        let month = calendar.component(.month, from: date)
        let chineseMonths = ["一月", "二月", "三月", "四月", "五月", "六月",
                            "七月", "八月", "九月", "十月", "十一月", "十二月"]
        return chineseMonths[month - 1]
    }
    
    /// 格式化日期标题（如：周三 12月18日）
    static func formatDayHeader(_ date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let weekdays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        return "\(weekdays[weekday-1]) \(month)月\(day)日"
    }
    
    /// 格式化当前时间（如：17:11）
    static func formatCurrentTime() -> String {
        let formatter = DateFormatter()
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