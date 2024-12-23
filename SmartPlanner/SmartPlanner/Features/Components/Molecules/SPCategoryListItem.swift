import SwiftUI

/// 计划类别列表项
/// 显示单个类别的信息，包括颜色标识、名称、子类别数量等
struct SPCategoryListItem: View {
    // MARK: - Properties
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    let name: String
    let color: Color
    let childCount: Int
    let level: Int
    let showArrow: Bool
    
    // 布局常量
    private let itemHeight: CGFloat = 44
    private let colorIndicatorSize: CGFloat = 12
    private let levelIndent: CGFloat = 20
    private let horizontalPadding: CGFloat = 16
    private let spacing: CGFloat = 8
    
    // MARK: - Initialization
    
    init(
        name: String,
        color: Color,
        childCount: Int = 0,
        level: Int = 0,
        showArrow: Bool = true
    ) {
        self.name = name
        self.color = color
        self.childCount = childCount
        self.level = level
        self.showArrow = showArrow
    }
    
    // MARK: - Private Views
    
    /// 颜色标识视图
    private var colorIndicator: some View {
        Circle()
            .fill(color)
            .frame(width: colorIndicatorSize, height: colorIndicatorSize)
    }
    
    /// 类别名称视图
    private var nameLabel: some View {
        Text(name)
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(themeManager.getThemeColor(.primaryText))
    }
    
    /// 子类别数量视图
    private var childCountLabel: some View {
        Group {
            if childCount > 0 {
                Text("\(childCount)")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(themeManager.getThemeColor(.secondaryText))
                    .frame(minWidth: 20)
            }
        }
    }
    
    /// 箭头图标视图
    private var arrowIcon: some View {
        Group {
            if showArrow {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(themeManager.getThemeColor(.secondaryText))
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: spacing) {
            // 缩进空间
            if level > 0 {
                Spacer()
                    .frame(width: CGFloat(level) * levelIndent)
            }
            
            // 颜色标识
            colorIndicator
            
            // 类别名称
            nameLabel
            
            Spacer()
            
            // 子类别数量
            childCountLabel
            
            // 箭头图标
            arrowIcon
        }
        .frame(height: itemHeight)
        .padding(.horizontal, horizontalPadding)
        .contentShape(Rectangle()) // 确保整行可点击
        .background(themeManager.getThemeColor(.background))
    }
}

// MARK: - Preview

#Preview("默认状态") {
    VStack(spacing: 0) {
        SPCategoryListItem(
            name: "工作",
            color: .blue,
            childCount: 3
        )
        
        SPCategoryListItem(
            name: "会议",
            color: .purple,
            childCount: 2,
            level: 1
        )
        
        SPCategoryListItem(
            name: "周会",
            color: .green,
            childCount: 0,
            level: 2
        )
        
        SPCategoryListItem(
            name: "休息",
            color: .orange,
            childCount: 0,
            level: 0,
            showArrow: false
        )
    }
    .environmentObject(ThemeManager.shared)
}

#Preview("深色模式") {
    SPCategoryListItem(
        name: "工作",
        color: .blue,
        childCount: 3
    )
    .environmentObject(ThemeManager.shared)
    .preferredColorScheme(.dark)
} 