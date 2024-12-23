import SwiftUI

/// 计划类别列表项
/// 显示单个类别的信息，包括颜色标识、名称、子类别数量等
struct SPCategoryListItem: View {
    // MARK: - Properties
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    let id: UUID
    let name: String
    let color: Color
    let childCount: Int
    let level: Int
    let isVisible: Bool
    let displayOrder: Int16
    let parentId: UUID?
    let showArrow: Bool
    let isExpanded: Bool
    
    // 布局常量
    private let itemHeight: CGFloat = 44
    private let colorIndicatorSize: CGFloat = 12
    private let levelIndent: CGFloat = 20
    private let horizontalPadding: CGFloat = 16
    private let spacing: CGFloat = 8
    
    // MARK: - Initialization
    
    init(
        id: UUID,
        name: String,
        color: Color,
        childCount: Int = 0,
        level: Int = 0,
        isVisible: Bool = true,
        displayOrder: Int16 = 0,
        parentId: UUID? = nil,
        showArrow: Bool = true,
        isExpanded: Bool = false
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.childCount = childCount
        self.level = level
        self.isVisible = isVisible
        self.displayOrder = displayOrder
        self.parentId = parentId
        self.showArrow = showArrow
        self.isExpanded = isExpanded
    }
    
    // MARK: - Private Views
    
    /// 颜色标识视图
    private var colorIndicator: some View {
        Circle()
            .fill(color)
            .frame(width: colorIndicatorSize, height: colorIndicatorSize)
            .opacity(isVisible ? 1.0 : 0.5)
    }
    
    /// 类别名称视图
    private var nameLabel: some View {
        Text(name)
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(themeManager.getThemeColor(.primaryText))
            .opacity(isVisible ? 1.0 : 0.5)
    }
    
    /// 子类别数量视图
    private var childCountLabel: some View {
        Group {
            if childCount > 0 && !isExpanded {
                Text("\(childCount)")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(themeManager.getThemeColor(.secondaryText))
                    .frame(minWidth: 20)
                    .opacity(isVisible ? 1.0 : 0.5)
            }
        }
    }
    
    /// 箭头图标视图
    private var arrowIcon: some View {
        Group {
            if showArrow && childCount > 0 {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(themeManager.getThemeColor(.secondaryText))
                    .opacity(isVisible ? 1.0 : 0.5)
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
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
            id: UUID(),
            name: "工作",
            color: .blue,
            childCount: 3,
            isExpanded: true
        )
        
        SPCategoryListItem(
            id: UUID(),
            name: "会议",
            color: .purple,
            childCount: 2,
            level: 1,
            displayOrder: 1
        )
        
        SPCategoryListItem(
            id: UUID(),
            name: "周会",
            color: .green,
            level: 2,
            displayOrder: 2
        )
        
        SPCategoryListItem(
            id: UUID(),
            name: "休息",
            color: .orange,
            isVisible: false,
            showArrow: false
        )
    }
    .environmentObject(ThemeManager.shared)
}

#Preview("深色模式") {
    SPCategoryListItem(
        id: UUID(),
        name: "工作",
        color: .blue,
        childCount: 3
    )
    .environmentObject(ThemeManager.shared)
    .preferredColorScheme(.dark)
} 