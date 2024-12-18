import Foundation

struct DateHelper {
    // MARK: - Properties
    
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // 设置周一为一周的第一天
        return calendar
    }()
    
    // MARK: - Date Calculations
    
    /// 检查日期是否是今天
    static func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    /// 获取农历日期
    static func lunarDay(for date: Date) -> String {
        let lunar = Calendar(identifier: .chinese)
        let components = lunar.dateComponents([.day], from: date)
        let lunarDay = components.day ?? 1
        return convertToChineseNumber(lunarDay)
    }
    
    /// 获取节日信息
    static func festivalInfo(for date: DateComponents) -> String? {
        // TODO: 实现节日判断逻辑
        return nil
    }
    
    /// 将 Date 转换为 DateComponents
    static func dateComponents(from date: Date, components: Set<Calendar.Component> = [.year, .month, .day]) -> DateComponents {
        return calendar.dateComponents(components, from: date)
    }
    
    /// 将 DateComponents 转换为 Date
    static func date(from components: DateComponents) -> Date? {
        return calendar.date(from: components)
    }
    
    // MARK: - Private Methods
    
    /// 将数字转换为中文数字
    private static func convertToChineseNumber(_ number: Int) -> String {
        let chineseNumbers = ["初", "十", "廿", "卅"]
        let digits = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
        
        if number == 1 {
            return "初一"
        } else if number == 10 {
            return "初十"
        } else if number == 20 {
            return "二十"
        } else if number == 30 {
            return "三十"
        }
        
        let decade = number / 10
        let unit = number % 10
        
        if unit == 0 {
            return "\(chineseNumbers[decade-1])十"
        } else if decade == 0 {
            return "初\(digits[unit-1])"
        } else if decade == 1 {
            return "十\(digits[unit-1])"
        } else if decade == 2 {
            return "廿\(digits[unit-1])"
        } else {
            return "卅\(digits[unit-1])"
        }
    }
} 