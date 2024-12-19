import SwiftUI

struct SPCalendarNavigationBar: View {
    // MARK: - Properties
    
    let onDismiss: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 导航栏内容
            HStack {
                // 返回按钮
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .foregroundColor(.red)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 4)
            
            // 底部分隔线
            Divider()
                .background(themeManager.getThemeColor(.calendarToolbarTint).opacity(0.2))
        }
        .background(themeManager.getThemeColor(.secondaryBackground))
    }
}

// MARK: - Preview

struct SPCalendarNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 浅色模式预览
            SPCalendarNavigationBar(
                onDismiss: {}
            )
            .environmentObject(ThemeManager.shared)
            .previewDisplayName("浅色模式")
            
            // 深色模式预览
            SPCalendarNavigationBar(
                onDismiss: {}
            )
            .environmentObject(ThemeManager.shared)
            .preferredColorScheme(.dark)
            .previewDisplayName("深色模式")
        }
    }
} 