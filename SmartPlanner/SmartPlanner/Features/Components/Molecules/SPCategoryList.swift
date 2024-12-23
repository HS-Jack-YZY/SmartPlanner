import SwiftUI

/// 类别列表组件
/// 管理和显示类别项的列表视图
struct SPCategoryList: View {
    // MARK: - Environment
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Properties
    
    /// 类别数据模型
    struct CategoryData: Identifiable {
        let id: UUID
        let name: String
        let color: Color
        let level: Int16
        let isVisible: Bool
        let displayOrder: Int16
        let parentId: UUID?
        let childCount: Int
        var isExpanded: Bool
    }
    
    /// 类别列表数据
    let categories: [CategoryData]
    
    /// 选中类别回调
    let onSelectCategory: ((UUID) -> Void)?
    
    /// 展开/折叠回调
    let onToggleExpand: ((UUID) -> Void)?
    
    // MARK: - Layout Constants
    
    private enum Layout {
        static let spacing: CGFloat = 0
        static let emptyStateSpacing: CGFloat = 8
        static let emptyStateImageSize: CGFloat = 60
        static let emptyStatePadding: CGFloat = 20
    }
    
    // MARK: - Initialization
    
    init(
        categories: [CategoryData],
        onSelectCategory: ((UUID) -> Void)? = nil,
        onToggleExpand: ((UUID) -> Void)? = nil
    ) {
        self.categories = categories
        self.onSelectCategory = onSelectCategory
        self.onToggleExpand = onToggleExpand
    }
    
    // MARK: - Private Views
    
    /// 空状态视图
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: Layout.emptyStateSpacing) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: Layout.emptyStateImageSize))
                .foregroundColor(themeManager.getThemeColor(.secondaryText))
            
            Text("No Categories")
                .font(.headline)
                .foregroundColor(themeManager.getThemeColor(.secondaryText))
            
            Text("Tap the button below to add")
                .font(.subheadline)
                .foregroundColor(themeManager.getThemeColor(.secondaryText))
        }
        .padding(Layout.emptyStatePadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if categories.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: Layout.spacing) {
                        ForEach(categories) { category in
                            SPCategoryItem(
                                id: category.id,
                                name: category.name,
                                color: category.color,
                                level: category.level,
                                isVisible: category.isVisible,
                                displayOrder: category.displayOrder,
                                parentId: category.parentId,
                                isExpanded: category.isExpanded,
                                showArrow: category.childCount > 0,
                                childCount: category.childCount,
                                onToggleExpand: {
                                    onToggleExpand?(category.id)
                                },
                                onSelect: {
                                    onSelectCategory?(category.id)
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview Provider

struct SPCategoryList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 有数据状态
            SPCategoryList(
                categories: [
                    .init(
                        id: UUID(),
                        name: "工作",
                        color: .blue,
                        level: 0,
                        isVisible: true,
                        displayOrder: 0,
                        parentId: nil,
                        childCount: 2,
                        isExpanded: true
                    ),
                    .init(
                        id: UUID(),
                        name: "会议",
                        color: .purple,
                        level: 1,
                        isVisible: true,
                        displayOrder: 0,
                        parentId: UUID(),
                        childCount: 1,
                        isExpanded: false
                    ),
                    .init(
                        id: UUID(),
                        name: "休息",
                        color: .orange,
                        level: 0,
                        isVisible: true,
                        displayOrder: 1,
                        parentId: nil,
                        childCount: 0,
                        isExpanded: false
                    )
                ],
                onSelectCategory: { id in
                    print("Selected category: \(id)")
                },
                onToggleExpand: { id in
                    print("Toggled category: \(id)")
                }
            )
            .environmentObject(ThemeManager.shared)
            .previewDisplayName("有数据状态")
            
            // 空状态
            SPCategoryList(categories: [])
                .environmentObject(ThemeManager.shared)
                .previewDisplayName("空状态")
            
            // 深色模式
            SPCategoryList(
                categories: [
                    .init(
                        id: UUID(),
                        name: "工作",
                        color: .blue,
                        level: 0,
                        isVisible: true,
                        displayOrder: 0,
                        parentId: nil,
                        childCount: 0,
                        isExpanded: false
                    )
                ]
            )
            .environmentObject(ThemeManager.shared)
            .preferredColorScheme(.dark)
            .previewDisplayName("深色模式")
        }
        .previewLayout(.sizeThatFits)
    }
} 