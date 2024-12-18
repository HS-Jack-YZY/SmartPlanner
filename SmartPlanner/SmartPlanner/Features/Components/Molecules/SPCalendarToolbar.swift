import SwiftUI

struct SPCalendarToolbar: View {
    // MARK: - Properties
    
    let isShowingDayView: Bool
    let onTodayButtonTapped: () -> Void
    let onViewModeButtonTapped: () -> Void
    let onInboxButtonTapped: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 30) {
            Button(action: onTodayButtonTapped) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.circle.fill")
                    Text("今天")
                }
                .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
            }
            
            Divider()
                .frame(height: 20)
                .background(Color.gray.opacity(0.3))
            
            Button(action: onViewModeButtonTapped) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text(isShowingDayView ? "月" : "日")
                }
                .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
            }
            
            Divider()
                .frame(height: 20)
                .background(Color.gray.opacity(0.3))
            
            Button(action: onInboxButtonTapped) {
                HStack(spacing: 4) {
                    Image(systemName: "tray")
                    Text("收件箱")
                }
                .foregroundColor(themeManager.getThemeColor(.calendarToolbarTint))
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 0)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}

// MARK: - Preview

struct SPCalendarToolbar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 日视图模式
            SPCalendarToolbar(
                isShowingDayView: true,
                onTodayButtonTapped: {},
                onViewModeButtonTapped: {},
                onInboxButtonTapped: {}
            )
            .environmentObject(ThemeManager.shared)
            .previewDisplayName("日视图模式")
            
            // 月视图模式
            SPCalendarToolbar(
                isShowingDayView: false,
                onTodayButtonTapped: {},
                onViewModeButtonTapped: {},
                onInboxButtonTapped: {}
            )
            .environmentObject(ThemeManager.shared)
            .preferredColorScheme(.dark)
            .previewDisplayName("月视图模式（深色）")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 