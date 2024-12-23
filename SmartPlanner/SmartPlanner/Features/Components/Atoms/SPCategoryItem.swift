import SwiftUI

/// 计划类别项
/// 显示单个类别的信息，包括颜色标识、名称、子类别数量等
struct SPCategoryItem: View {
    // MARK: - Environment
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Properties
    
    // 数据属性
    let id: UUID                 // 类别唯一标识
    let name: String            // 类别名称
    let color: Color            // 类别颜色
    let level: Int16            // 层级深度（0-5）
    let isVisible: Bool         // 是否可见
    let displayOrder: Int16     // 显示顺序（同级别内排序，值越小越靠前）
    let parentId: UUID?         // 父类别ID（可选，level=0时为nil）
    
    // UI 状态
    let isExpanded: Bool        // 是否展开子列表
    let showArrow: Bool         // 是否显示箭头
    let childCount: Int         // 子类别数量
    
    // 回调函数
    let onToggleExpand: (() -> Void)?  // 展开/折叠回调
    let onSelect: (() -> Void)?        // 选中回调
    
    // MARK: - Layout Constants
    
    private enum Layout {
        static let itemHeight: CGFloat = 44
        static let colorIndicatorSize: CGFloat = 12
        static let levelIndent: CGFloat = 20
        static let horizontalPadding: CGFloat = 16
        static let spacing: CGFloat = 8
        static let arrowTapArea: CGFloat = 44
        
        static let nameFont: Font = .system(size: 17, weight: .regular)
        static let countFont: Font = .system(size: 15, weight: .regular)
        static let arrowFont: Font = .system(size: 12, weight: .semibold)
        
        static let activeOpacity: Double = 1.0
        static let inactiveOpacity: Double = 0.5
    }
    
    // MARK: - Initialization
    
    /// 初始化类别项
    /// - Parameters:
    ///   - id: 类别唯一标识
    ///   - name: 类别名称
    ///   - color: 类别颜色
    ///   - level: 层级深度（0-5），0表示根类别
    ///   - isVisible: 是否可见
    ///   - displayOrder: 显示顺序（在同一层级内，值越小越靠前）
    ///   - parentId: 父类别ID（level=0时为nil）
    ///   - isExpanded: 是否展开子列表
    ///   - showArrow: 是否显示箭头
    ///   - childCount: 子类别数量
    ///   - onToggleExpand: 展开/折叠回调
    ///   - onSelect: 选中回调
    init(
        id: UUID,
        name: String,
        color: Color,
        level: Int16 = 0,
        isVisible: Bool = true,
        displayOrder: Int16 = 0,
        parentId: UUID? = nil,
        isExpanded: Bool = false,
        showArrow: Bool = true,
        childCount: Int = 0,
        onToggleExpand: (() -> Void)? = nil,
        onSelect: (() -> Void)? = nil
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.level = level
        self.isVisible = isVisible
        self.displayOrder = displayOrder
        self.parentId = parentId
        self.isExpanded = isExpanded
        self.showArrow = showArrow
        self.childCount = childCount
        self.onToggleExpand = onToggleExpand
        self.onSelect = onSelect
    }
    
    // MARK: - Private Views
    
    /// 颜色标识视图
    private var colorIndicator: some View {
        Circle()
            .fill(color)
            .frame(width: Layout.colorIndicatorSize, height: Layout.colorIndicatorSize)
            .opacity(isVisible ? Layout.activeOpacity : Layout.inactiveOpacity)
            .accessibilityHidden(true)
    }
    
    /// 类别名称视图
    private var nameLabel: some View {
        Text(name)
            .font(Layout.nameFont)
            .foregroundColor(themeManager.getThemeColor(.primaryText))
            .opacity(isVisible ? Layout.activeOpacity : Layout.inactiveOpacity)
            .accessibilityLabel(Text("类别：\(name)"))
            .accessibilityAddTraits(.isButton)
    }
    
    /// 子类别数量视图
    private var childCountLabel: some View {
        Group {
            if childCount > 0 && !isExpanded {
                Text("\(childCount)")
                    .font(Layout.countFont)
                    .foregroundColor(themeManager.getThemeColor(.secondaryText))
                    .frame(minWidth: 20)
                    .opacity(isVisible ? Layout.activeOpacity : Layout.inactiveOpacity)
                    .accessibilityLabel(Text("包含\(childCount)个子类别"))
            }
        }
    }
    
    /// 箭头图标视图
    private var arrowIcon: some View {
        Group {
            if showArrow && childCount > 0 {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(Layout.arrowFont)
                    .foregroundColor(themeManager.getThemeColor(.secondaryText))
                    .opacity(isVisible ? Layout.activeOpacity : Layout.inactiveOpacity)
                    .frame(width: Layout.arrowTapArea, height: Layout.arrowTapArea)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            onToggleExpand?()
                        }
                    }
                    .accessibilityLabel(Text(isExpanded ? "折叠" : "展开"))
                    .accessibilityAddTraits(.isButton)
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: Layout.spacing) {
            // 缩进空间
            if level > 0 {
                Spacer()
                    .frame(width: CGFloat(level) * Layout.levelIndent)
                    .accessibilityHidden(true)
            }
            
            // 颜色标识
            colorIndicator
            
            // 类别名称
            nameLabel
            
            Spacer(minLength: Layout.spacing)
            
            // 子类别数量
            childCountLabel
            
            // 箭头图标
            arrowIcon
        }
        .frame(height: Layout.itemHeight)
        .padding(.horizontal, Layout.horizontalPadding)
        .contentShape(Rectangle())
        .background(themeManager.getThemeColor(.background))
        .onTapGesture {
            onSelect?()
        }
    }
}

// MARK: - Preview Provider

struct SPCategoryItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 默认状态预览
            VStack(spacing: 0) {
                SPCategoryItem(
                    id: UUID(),
                    name: "工作",
                    color: .blue,
                    isExpanded: true,
                    childCount: 3,
                    onToggleExpand: {
                        print("Toggle 工作")
                    },
                    onSelect: {
                        print("Select 工作")
                    }
                )
                
                SPCategoryItem(
                    id: UUID(),
                    name: "会议",
                    color: .purple,
                    level: 1,
                    displayOrder: 1,
                    childCount: 2,
                    onToggleExpand: {
                        print("Toggle 会议")
                    },
                    onSelect: {
                        print("Select 会议")
                    }
                )
                
                SPCategoryItem(
                    id: UUID(),
                    name: "周会",
                    color: .green,
                    level: 2,
                    displayOrder: 2,
                    onSelect: {
                        print("Select 周会")
                    }
                )
                
                SPCategoryItem(
                    id: UUID(),
                    name: "休息",
                    color: .orange,
                    isVisible: false,
                    showArrow: false,
                    onSelect: {
                        print("Select 休息")
                    }
                )
            }
            .environmentObject(ThemeManager.shared)
            .previewDisplayName("默认状态")
            
            // 深色模式预览
            SPCategoryItem(
                id: UUID(),
                name: "工作",
                color: .blue,
                childCount: 3,
                onToggleExpand: {
                    print("Toggle 工作")
                },
                onSelect: {
                    print("Select 工作")
                }
            )
            .environmentObject(ThemeManager.shared)
            .preferredColorScheme(.dark)
            .previewDisplayName("深色模式")
        }
    }
} 
