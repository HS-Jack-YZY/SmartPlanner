import Foundation

struct DateHelper {
    // MARK: - Properties
    
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // 设置周一为一周的第一天
        return calendar
    }()
    
    // MARK: - Date Calculations
    
    /// 获取某个月的所有日期
    /// - Parameter date: 目标月份中的任意一天
    /// - Returns: 包含所有日期的数组，以及每个日期在日历网格中的位置偏移
    static func getDaysInMonth(for date: Date) -> [(date: Date, offset: Int)] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: monthInterval.start))
        else { return [] }
        
        // 计算月初是星期几（0是周一，6是周日）
        let weekday = calendar.component(.weekday, from: monthStart)
        let offset = (weekday + 5) % 7 // 转换为以周一为起点的偏移量
        
        // 获取这个月的总天数
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 0
        
        var dates: [(Date, Int)] = []
        
        // 添加当月的日期
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                dates.append((date, offset))
            }
        }
        
        return dates
    }
    
    /// 检查日期是否是今天
    static func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    /// 检查日期是否在指定月份内
    static func isInSameMonth(_ date: Date, as month: Date) -> Bool {
        calendar.isDate(date, equalTo: month, toGranularity: .month)
    }
    
    /// 获取月份标题
    static func monthTitle(for date: Date) -> String {
        "\(calendar.component(.month, from: date))月"
    }
    
    /// 获取年份标题
    static func yearTitle(for date: Date) -> String {
        "\(calendar.component(.year, from: date))年"
    }
    
    /// 获取星期标题
    static func weekdaySymbols() -> [String] {
        ["一", "二", "三", "四", "五", "六", "日"]
    }
    
    /// 获取农历日期
    static func lunarDay(for date: Date) -> String {
        let lunar = Calendar(identifier: .chinese)
        let components = lunar.dateComponents([.day], from: date)
        let lunarDay = components.day ?? 1
        return convertToChineseNumber(lunarDay)
    }
    
    /// 检查是否是周末
    static func isWeekend(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
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