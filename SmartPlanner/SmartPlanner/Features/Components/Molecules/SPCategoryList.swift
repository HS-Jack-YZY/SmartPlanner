import SwiftUI

/// Category model for list display
struct CategoryData: Identifiable, Equatable {
    let id: UUID
    let name: String
    let color: Color
    let level: Int16
    let isVisible: Bool
    let displayOrder: Int16
    let parentId: UUID?
    var isExpanded: Bool
    let childIds: [UUID]
    
    static func == (lhs: CategoryData, rhs: CategoryData) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Toggle expansion state
    mutating func toggleExpansion() {
        isExpanded.toggle()
    }
}

/// 类别列表管理组件
/// 负责管理和显示类别项的列表，处理层级关系和展开/折叠状态
struct SPCategoryList: View {
    // MARK: - Environment
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Properties
    
    /// Category data model
    @State private var categories: [CategoryData]
    
    /// Category selection callback
    private let onSelectCategory: ((CategoryData) -> Void)?
    
    /// Category expansion state callback
    private let onToggleExpand: ((CategoryData) -> Void)?
    
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
        onSelectCategory: ((CategoryData) -> Void)? = nil,
        onToggleExpand: ((CategoryData) -> Void)? = nil
    ) {
        _categories = State(initialValue: categories)
        self.onSelectCategory = onSelectCategory
        self.onToggleExpand = onToggleExpand
    }
    
    // MARK: - Private Methods
    
    /// Toggle category expansion state
    private func toggleCategory(_ targetCategory: CategoryData) {
        categories = updateCategoryExpansion(in: categories, targetId: targetCategory.id)
        if let updatedCategory = findCategory(id: targetCategory.id, in: categories) {
            onToggleExpand?(updatedCategory)
        }
    }
    
    /// Update category expansion state recursively
    private func updateCategoryExpansion(in categories: [CategoryData], targetId: UUID) -> [CategoryData] {
        var updatedCategories = categories
        
        for index in updatedCategories.indices {
            if updatedCategories[index].id == targetId {
                updatedCategories[index].toggleExpansion()
                return updatedCategories
            }
        }
        
        return updatedCategories
    }
    
    /// Find category by id
    private func findCategory(id: UUID, in categories: [CategoryData]) -> CategoryData? {
        categories.first { $0.id == id }
    }
    
    /// Get children for a category
    private func getChildren(for category: CategoryData) -> [CategoryData] {
        category.childIds.compactMap { childId in
            findCategory(id: childId, in: categories)
        }.sorted { $0.displayOrder < $1.displayOrder }
    }
    
    /// Get visible categories based on expansion state
    private var visibleCategories: [CategoryData] {
        var result: [CategoryData] = []
        
        // Process root categories first (level 0)
        let rootCategories = categories.filter { $0.parentId == nil }
            .sorted { $0.displayOrder < $1.displayOrder }
        
        for category in rootCategories {
            // Add root category
            result.append(category)
            
            // Add visible children if expanded
            if category.isExpanded {
                result.append(contentsOf: getVisibleChildren(category))
            }
        }
        
        return result
    }
    
    /// Get visible children for a category
    private func getVisibleChildren(_ parent: CategoryData) -> [CategoryData] {
        var result: [CategoryData] = []
        
        let children = getChildren(for: parent)
        for child in children {
            // Add child category
            result.append(child)
            
            // Recursively add children if expanded
            if child.isExpanded {
                result.append(contentsOf: getVisibleChildren(child))
            }
        }
        
        return result
    }
    
    // MARK: - Private Views
    
    /// Empty state view
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
                        ForEach(visibleCategories) { category in
                            SPCategoryItem(
                                id: category.id,
                                name: category.name,
                                color: category.color,
                                level: category.level,
                                isVisible: category.isVisible,
                                displayOrder: category.displayOrder,
                                parentId: category.parentId,
                                isExpanded: category.isExpanded,
                                showArrow: !category.childIds.isEmpty,
                                childCount: category.childIds.count,
                                onToggleExpand: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        toggleCategory(category)
                                    }
                                },
                                onSelect: {
                                    onSelectCategory?(category)
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
            // With data
            SPCategoryList(
                categories: {
                    let weeklyId = UUID()
                    let meetingsId = UUID()
                    let workId = UUID()
                    
                    return [
                        CategoryData(
                            id: workId,
                            name: "Work",
                            color: .blue,
                            level: 0,
                            isVisible: true,
                            displayOrder: 0,
                            parentId: nil,
                            isExpanded: true,
                            childIds: [meetingsId]
                        ),
                        CategoryData(
                            id: meetingsId,
                            name: "Meetings",
                            color: .purple,
                            level: 1,
                            isVisible: true,
                            displayOrder: 0,
                            parentId: workId,
                            isExpanded: false,
                            childIds: [weeklyId]
                        ),
                        CategoryData(
                            id: weeklyId,
                            name: "Weekly",
                            color: .green,
                            level: 2,
                            isVisible: true,
                            displayOrder: 0,
                            parentId: meetingsId,
                            isExpanded: false,
                            childIds: []
                        ),
                        CategoryData(
                            id: UUID(),
                            name: "Personal",
                            color: .orange,
                            level: 0,
                            isVisible: true,
                            displayOrder: 1,
                            parentId: nil,
                            isExpanded: false,
                            childIds: []
                        )
                    ]
                }()
            )
            .environmentObject(ThemeManager.shared)
            .previewDisplayName("With Data")
            
            // Empty state
            SPCategoryList(categories: [])
                .environmentObject(ThemeManager.shared)
                .previewDisplayName("Empty State")
            
            // Dark mode
            SPCategoryList(
                categories: [
                    CategoryData(
                        id: UUID(),
                        name: "Work",
                        color: .blue,
                        level: 0,
                        isVisible: true,
                        displayOrder: 0,
                        parentId: nil,
                        isExpanded: false,
                        childIds: []
                    )
                ]
            )
            .environmentObject(ThemeManager.shared)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        .previewLayout(.sizeThatFits)
    }
} 