import SwiftUI

struct SPCalendarDayView: View {
    // MARK: - Properties
    
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isInCurrentMonth: Bool
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 4) {
            // 公历日期
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 17, weight: isToday ? .medium : .regular))
                .foregroundColor(textColor)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(backgroundColor)
                )
            
            // 农历日期
            Text(DateHelper.lunarDay(for: date))
                .font(.system(size: 11))
                .foregroundColor(lunarTextColor)
        }
        .frame(height: 60)
    }
    
    // MARK: - Computed Properties
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if !isInCurrentMonth {
            return .gray
        } else if DateHelper.isWeekend(date) {
            return .gray
        } else if isToday {
            return .red
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .red
        } else {
            return .clear
        }
    }
    
    private var lunarTextColor: Color {
        if isSelected {
            return .white
        } else if !isInCurrentMonth {
            return .gray.opacity(0.5)
        } else {
            return .gray
        }
    }
}

// MARK: - Preview

struct SPCalendarDayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Normal day
            SPCalendarDayView(
                date: Date(),
                isSelected: false,
                isToday: false,
                isInCurrentMonth: true
            )
            
            // Today
            SPCalendarDayView(
                date: Date(),
                isSelected: false,
                isToday: true,
                isInCurrentMonth: true
            )
            
            // Selected day
            SPCalendarDayView(
                date: Date(),
                isSelected: true,
                isToday: false,
                isInCurrentMonth: true
            )
            
            // Out of month
            SPCalendarDayView(
                date: Date(),
                isSelected: false,
                isToday: false,
                isInCurrentMonth: false
            )
        }
        .environmentObject(ThemeManager.shared)
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 