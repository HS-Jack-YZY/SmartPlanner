import SwiftUI

/// 时间轴内容视图，用于显示日历的时间轴和内容区域
/// 支持显示多天的时间轴和对应的内容
///
/// 该视图包含：
/// - 左侧时间轴列：显示每小时的时间标记
/// - 右侧内容列：显示每天的时间格子，支持多天显示
///
/// - Note: 该视图通过 `ThemeManager` 环境对象管理主题样式
struct SPTimelineContentView: View {
    // MARK: - Properties
    
    /// 需要显示的日期数组
    let dates: [Date]
    /// 每小时的高度
    let hourHeight: CGFloat
    /// 时间轴开始小时（24小时制）
    let timelineStartHour: Int
    /// 时间轴结束小时（24小时制）
    let timelineEndHour: Int
    /// 时间列的宽度
    let timeColumnWidth: CGFloat
    /// 每天列的宽度
    let dayColumnWidth: CGFloat
    /// 主题管理器
    @EnvironmentObject private var themeManager: ThemeManager
    /// 当前时间
    @State private var currentDate = Date()
    /// 计时器
    @State private var timer: Timer?
    /// 视图几何信息
    @State private var scrollViewHeight: CGFloat = 0
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    HStack(spacing: 0) {
                        timelineColumn
                        contentColumns
                    }
                    .frame(minHeight: CGFloat(timelineEndHour - timelineStartHour) * hourHeight)
                }
                .onChange(of: scrollViewHeight) { _ in
                    scrollToCurrentTime(proxy: proxy)
                }
                .onAppear {
                    scrollViewHeight = geometry.size.height
                    // 立即更新一次当前时间
                    currentDate = Date()
                    // 创建一个每分钟更新一次的计时器
                    timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                        withAnimation(.linear(duration: 0.3)) {
                            currentDate = Date()
                        }
                    }
                    // 确保计时器在主线程运行
                    RunLoop.main.add(timer!, forMode: .common)
                    
                    // 延迟一下以确保视图已经加载完成
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToCurrentTime(proxy: proxy)
                    }
                }
                .onDisappear {
                    // 清理计时器
                    timer?.invalidate()
                    timer = nil
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// 滚动到当前时间位置
    private func scrollToCurrentTime(proxy: ScrollViewProxy) {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentDate)
        let currentMinute = calendar.component(.minute, from: currentDate)
        
        if currentHour >= timelineStartHour && currentHour < timelineEndHour {
            let totalOffset = CGFloat(currentHour - timelineStartHour) * hourHeight + 
                            hourHeight * CGFloat(currentMinute) / 60.0
            // 计算目标偏移量，使当前时间位于屏幕三分之一处
            let targetOffset = max(0, totalOffset - scrollViewHeight / 3)
            
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(timelineStartHour, anchor: .top)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(timelineStartHour + Int(targetOffset / hourHeight), anchor: .top)
                    }
                }
            }
        }
    }
    
    // MARK: - Private Views
    
    /// 时间轴列视图
    /// 显示从起始时间到结束时间的每个小时
    private var timelineColumn: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                ForEach(timelineStartHour..<timelineEndHour, id: \.self) { hour in
                    TimelineHourCell(hour: hour, themeManager: themeManager)
                        .frame(width: timeColumnWidth, height: hourHeight)
                }
            }
            .overlay(
                Rectangle()
                    .fill(themeManager.getThemeColor(.secondaryText).opacity(0.2))
                    .frame(width: 0.5),
                alignment: .trailing
            )
            
            currentTimeIndicator
        }
    }
    
    /// 当前时间指示器视图
    /// 显示当前时间的标记和延伸线
    @ViewBuilder
    private var currentTimeIndicator: some View {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentDate)
        let currentMinute = calendar.component(.minute, from: currentDate)
        
        if currentHour >= timelineStartHour && currentHour < timelineEndHour {
            let offset = CGFloat(currentHour - timelineStartHour) * hourHeight + 
                        hourHeight * CGFloat(currentMinute) / 60.0
            
            ZStack(alignment: .leading) {
                // 时间标记背景和文本
                Text(String(format: "%02d:%02d", currentHour, currentMinute))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(width: timeColumnWidth - 16, alignment: .trailing)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.red)
                    )
                    .offset(x: 2)
                    .id(currentDate)
                
                // 延伸线
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 16, height: 2)
                    .offset(x: timeColumnWidth - 2)
            }
            .offset(y: offset - 11)
            .zIndex(1)
        }
    }
    
    /// 内容列视图
    /// 为每一天创建一个时间格子列
    private var contentColumns: some View {
        HStack(spacing: 0) {
            ForEach(dates, id: \.self) { date in
                TimelineContentColumn(
                    date: date,
                    hourHeight: hourHeight,
                    timelineStartHour: timelineStartHour,
                    timelineEndHour: timelineEndHour,
                    themeManager: themeManager,
                    currentDate: currentDate
                )
                .frame(width: dayColumnWidth)
                .overlay(
                    Rectangle()
                        .fill(themeManager.getThemeColor(.secondaryText).opacity(0.2))
                        .frame(width: 0.5),
                    alignment: .trailing
                )
            }
        }
    }
}

// MARK: - Supporting Views

/// 时间轴小时单元格视图
/// 显示每个小时的时间标记
private struct TimelineHourCell: View {
    /// 当前小时（24小时制）
    let hour: Int
    /// 主题管理器
    let themeManager: ThemeManager
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(themeManager.getThemeColor(.background))
                // .overlay(
                //     Rectangle()
                //         .fill(themeManager.getThemeColor(.secondaryText).opacity(0.2))
                //         .frame(height: 0.5),
                //     alignment: .top
                // )
            
            Text(String(format: "%02d:00", hour))
                .font(.system(size: 13))
                .foregroundColor(themeManager.getThemeColor(.secondaryText))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 8)
                .offset(y: -8)
        }
    }
}

/// 时间轴内容列视图
/// 显示某一天的时间格子
private struct TimelineContentColumn: View {
    /// 当前日期
    let date: Date
    /// 每小时的高度
    let hourHeight: CGFloat
    /// 时间轴开始小时
    let timelineStartHour: Int
    /// 时间轴结束小时
    let timelineEndHour: Int
    /// 主题管理器
    let themeManager: ThemeManager
    /// 当前时间
    let currentDate: Date
    
    /// 获取时间线的颜色和透明度
    private var timelineColor: Color {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        return Color.red.opacity(isToday ? 1.0 : 0.3)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ForEach(timelineStartHour..<timelineEndHour, id: \.self) { hour in
                    TimelineHourSlot(
                        date: date,
                        hour: hour,
                        hourHeight: hourHeight,
                        themeManager: themeManager,
                        currentDate: currentDate
                    )
                    .frame(height: hourHeight)
                }
            }
            
            // 当前时间指示器
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: currentDate)
            let currentMinute = calendar.component(.minute, from: currentDate)
            
            if currentHour >= timelineStartHour && currentHour < timelineEndHour {
                let offset = CGFloat(currentHour - timelineStartHour) * hourHeight + 
                            hourHeight * CGFloat(currentMinute) / 60.0
                
                Rectangle()
                    .fill(timelineColor)
                    .frame(height: 2)
                    .shadow(color: timelineColor.opacity(0.2), radius: 1, y: 1)
                    .offset(y: offset)
                    .animation(.linear(duration: 0.3), value: currentDate)
            }
        }
    }
}

/// 时间格子图
/// 显示某一天某一小时的时间格子，包括当前时间指示器
private struct TimelineHourSlot: View {
    /// 当前日期
    let date: Date
    /// 当前小时
    let hour: Int
    /// 小时格子高度
    let hourHeight: CGFloat
    /// 主题管理器
    let themeManager: ThemeManager
    /// 当前时间
    let currentDate: Date
    
    /// 判断是否为当前小时
    private var isCurrentHour: Bool {
        let calendar = Calendar.current
        return calendar.component(.hour, from: currentDate) == hour
    }
    
    /// 获取时间线的颜色和透明度
    private var timelineColor: Color {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        return Color.red.opacity(isToday ? 1.0 : 0.3)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(themeManager.getThemeColor(.background))
                .overlay(
                    Rectangle()
                        .fill(themeManager.getThemeColor(.secondaryText).opacity(0.2))
                        .frame(height: 0.5),
                    alignment: .top
                )
            
            if isCurrentHour {
                let calendar = Calendar.current
                let currentMinute = calendar.component(.minute, from: currentDate)
                let minuteOffset = hourHeight * CGFloat(currentMinute) / 60.0
                
                Rectangle()
                    .fill(timelineColor)
                    .frame(height: 2)
                    .shadow(
                        color: timelineColor.opacity(0.2),
                        radius: 1,
                        y: 1
                    )
                    .offset(y: minuteOffset)
                    .animation(.linear(duration: 0.3), value: currentDate)
            }
        }
    }
}

// MARK: - Preview

#Preview("Timeline Content") {
    SPTimelineContentView(
        dates: [Date(), Date().addingTimeInterval(86400)],
        hourHeight: 60,
        timelineStartHour: 0,
        timelineEndHour: 24,
        timeColumnWidth: 50,
        dayColumnWidth: (UIScreen.main.bounds.width - 50) / 4
    )
    .environmentObject(ThemeManager.shared)
} 