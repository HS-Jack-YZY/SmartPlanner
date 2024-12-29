import SwiftUI

struct SPBottomToolbar: View {
    // MARK: - Properties
    
    @Binding var selectedTab: Int
    @EnvironmentObject private var themeManager: ThemeManager
    
    private let tabs = [
        (title: "类别", icon: "square.grid.2x2.fill"),
        (title: "区间", icon: "clock.fill"),
        (title: "计划", icon: "list.bullet.clipboard.fill"),
        (title: "统计", icon: "chart.bar.fill")
    ]
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: { selectedTab = index }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].icon)
                            .imageScale(.medium)
                            .symbolRenderingMode(.hierarchical)
                        
                        Text(tabs[index].title)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedTab == index ?
                        themeManager.getThemeColor(.primary) :
                        themeManager.getThemeColor(.secondaryText))
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, max(UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0, 8))
        .background(
            Rectangle()
                .fill(themeManager.getThemeColor(.secondaryBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -4)
                .overlay(
                    Rectangle()
                        .fill(themeManager.getThemeColor(.secondaryText).opacity(0.1))
                        .frame(height: 0.5)
                        .frame(maxHeight: .infinity, alignment: .top)
                )
        )
    }
}

// MARK: - Preview

#Preview("浅色模式", traits: .sizeThatFitsLayout) {
    // 浅色模式预览
    SPBottomToolbar(selectedTab: .constant(0))
        .environmentObject(ThemeManager.shared)
}

#Preview("深色模式", traits: .sizeThatFitsLayout) {
    // 深色模式预览
    SPBottomToolbar(selectedTab: .constant(1))
        .environmentObject(ThemeManager.shared)
        .preferredColorScheme(.dark)
} 
