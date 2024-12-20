import SwiftUI

struct SPScrollableMonthCalendarView: View {
    // MARK: - Properties
    
    @Binding var currentMonth: Date
    @State private var visibleMonths: [Date] = []
    @State private var isLoadingMore = false
    @State private var scrolledToInitial = false
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    private let calendar = Calendar.current
    private let initialMonthRange = (-2...2)
    private let batchSize = 3
    
    // MARK: - Initialization
    
    init(currentMonth: Binding<Date>) {
        self._currentMonth = currentMonth
    }
    
    // MARK: - Helper Methods
    
    private func initializeMonths() {
        visibleMonths = initialMonthRange.compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: currentMonth)
        }
    }
    
    private func loadMoreMonths(direction: LoadDirection) {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        
        let baseMonth = direction == .forward ? visibleMonths.last! : visibleMonths.first!
        let newMonths = (1...batchSize).compactMap { offset in
            calendar.date(
                byAdding: .month,
                value: direction == .forward ? offset : -offset,
                to: baseMonth
            )
        }
        
        withAnimation {
            if direction == .forward {
                visibleMonths.append(contentsOf: newMonths)
            } else {
                visibleMonths.insert(contentsOf: newMonths, at: 0)
            }
        }
        
        isLoadingMore = false
    }
    
    private func scrollToMonth(_ targetMonth: Date, proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(targetMonth, anchor: .center)
        }
    }
    
    private func handleMonthAppearance(_ month: Date) {
        if month == visibleMonths.last {
            loadMoreMonths(direction: .forward)
        } else if month == visibleMonths.first {
            loadMoreMonths(direction: .backward)
        }
        
        // 更新当前月份
        if calendar.isDate(month, equalTo: currentMonth, toGranularity: .month) {
            currentMonth = month
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(visibleMonths, id: \.self) { month in
                        SPMonthCalendarView(month: month)
                            .id(month)
                            .onAppear {
                                handleMonthAppearance(month)
                            }
                    }
                }
            }
            .onAppear {
                initializeMonths()
                // 确保只在第一次出现时滚动到当前月份
                if !scrolledToInitial {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToMonth(currentMonth, proxy: proxy)
                        scrolledToInitial = true
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Types

private enum LoadDirection {
    case forward
    case backward
}

// MARK: - Preview

#Preview("当前月份") {
    SPScrollableMonthCalendarView(currentMonth: .constant(Date()))
        .environmentObject(ThemeManager.shared)
}

#Preview("深色模式") {
    SPScrollableMonthCalendarView(currentMonth: .constant(Date()))
        .environmentObject(ThemeManager.shared)
        .preferredColorScheme(.dark)
} 