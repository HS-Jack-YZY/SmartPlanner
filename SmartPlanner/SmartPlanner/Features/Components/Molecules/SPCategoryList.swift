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
    
    /// Category expansion states cache
    @State private var expansionStates: [UUID: Bool] = [:]
    
    /// Currently dragged category ID
    @State private var draggingCategoryId: UUID?
    
    /// Current drag position
    @State private var currentDragPosition: CGPoint?
    
    /// Overlapped category ID
    @State private var overlappedCategoryId: UUID?
    
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
        static let itemHeight: CGFloat = 40
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
        
        // Initialize expansion states
        var initialStates: [UUID: Bool] = [:]
        for category in categories {
            initialStates[category.id] = category.isExpanded
        }
        _expansionStates = State(initialValue: initialStates)
    }
    
    // MARK: - Private Methods
    
    /// Toggle category expansion state
    private func toggleCategory(_ targetCategory: CategoryData) {
        // Update expansion state
        expansionStates[targetCategory.id] = !(expansionStates[targetCategory.id] ?? false)
        
        // Update category
        if let index = categories.firstIndex(where: { $0.id == targetCategory.id }) {
            var updatedCategory = categories[index]
            updatedCategory.isExpanded = expansionStates[targetCategory.id] ?? false
            categories[index] = updatedCategory
            onToggleExpand?(updatedCategory)
        }
    }
    
    /// Get children for a category
    private func getChildren(for category: CategoryData) -> [CategoryData] {
        category.childIds.compactMap { childId in
            categories.first { $0.id == childId }
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
            if expansionStates[category.id] ?? false {
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
            if expansionStates[child.id] ?? false {
                result.append(contentsOf: getVisibleChildren(child))
            }
        }
        
        return result
    }
    
    /// Handle drag start
    private func handleDragStart(_ categoryId: UUID) {
        draggingCategoryId = categoryId
        overlappedCategoryId = nil
    }
    
    /// Handle drag position change
    private func handleDragChange(_ categoryId: UUID, _ position: CGPoint) {
        currentDragPosition = position
        
        // Find overlapped category
        if let draggedCategory = categories.first(where: { $0.id == categoryId }) {
            // Check for overlap with other categories
            for category in visibleCategories {
                if category.id != categoryId {
                    // Calculate vertical distance
                    let categoryY = CGFloat(visibleCategories.firstIndex(where: { $0.id == category.id }) ?? 0) * Layout.itemHeight
                    let distance = abs(position.y - categoryY)
                    
                    if distance < Layout.itemHeight {
                        overlappedCategoryId = category.id
                        return
                    }
                }
            }
        }
        
        // No overlap found
        overlappedCategoryId = nil
    }
    
    /// Handle drag end
    private func handleDragEnd(_ categoryId: UUID, _ position: CGPoint) {
        draggingCategoryId = nil
        currentDragPosition = nil
        overlappedCategoryId = nil
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
                                isExpanded: expansionStates[category.id] ?? false,
                                showArrow: !category.childIds.isEmpty,
                                childCount: category.childIds.count,
                                isOverlapped: category.id == overlappedCategoryId,
                                onToggleExpand: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        toggleCategory(category)
                                    }
                                },
                                onSelect: {
                                    onSelectCategory?(category)
                                },
                                onDragStarted: { id in
                                    handleDragStart(id)
                                },
                                onDragChanged: { id, location in
                                    handleDragChange(id, location)
                                },
                                onDragEnded: { id, location in
                                    handleDragEnd(id, location)
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

#Preview("With Data", traits: .sizeThatFitsLayout) {
    // With data
    SPCategoryList(
        categories: {
            let workId = UUID()
            let meetingsId = UUID()
            let weeklyId = UUID()
            let monthlyId = UUID()
            let projectsId = UUID()
            let projectAId = UUID()
            let projectBId = UUID()
            let personalId = UUID()
            let fitnessId = UUID()
            let yogaId = UUID()
            let studyId = UUID()
            let languageId = UUID()
            
            return [
                // Work Category
                CategoryData(
                    id: workId,
                    name: "Work",
                    color: .blue,
                    level: 0,
                    isVisible: true,
                    displayOrder: 0,
                    parentId: nil,
                    isExpanded: true,
                    childIds: [meetingsId, projectsId]
                ),
                // Meetings Category
                CategoryData(
                    id: meetingsId,
                    name: "Meetings",
                    color: .purple,
                    level: 1,
                    isVisible: true,
                    displayOrder: 0,
                    parentId: workId,
                    isExpanded: true,
                    childIds: [weeklyId, monthlyId]
                ),
                // Weekly Meetings
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
                // Monthly Meetings
                CategoryData(
                    id: monthlyId,
                    name: "Monthly",
                    color: .mint,
                    level: 2,
                    isVisible: true,
                    displayOrder: 1,
                    parentId: meetingsId,
                    isExpanded: false,
                    childIds: []
                ),
                // Projects Category
                CategoryData(
                    id: projectsId,
                    name: "Projects",
                    color: .indigo,
                    level: 1,
                    isVisible: true,
                    displayOrder: 1,
                    parentId: workId,
                    isExpanded: true,
                    childIds: [projectAId, projectBId]
                ),
                // Project A
                CategoryData(
                    id: projectAId,
                    name: "Project A",
                    color: .cyan,
                    level: 2,
                    isVisible: true,
                    displayOrder: 0,
                    parentId: projectsId,
                    isExpanded: false,
                    childIds: []
                ),
                // Project B
                CategoryData(
                    id: projectBId,
                    name: "Project B",
                    color: .teal,
                    level: 2,
                    isVisible: true,
                    displayOrder: 1,
                    parentId: projectsId,
                    isExpanded: false,
                    childIds: []
                ),
                // Personal Category
                CategoryData(
                    id: personalId,
                    name: "Personal",
                    color: .orange,
                    level: 0,
                    isVisible: true,
                    displayOrder: 1,
                    parentId: nil,
                    isExpanded: true,
                    childIds: [fitnessId, studyId]
                ),
                // Fitness Category
                CategoryData(
                    id: fitnessId,
                    name: "Fitness",
                    color: .red,
                    level: 1,
                    isVisible: true,
                    displayOrder: 0,
                    parentId: personalId,
                    isExpanded: true,
                    childIds: [yogaId]
                ),
                // Yoga
                CategoryData(
                    id: yogaId,
                    name: "Yoga",
                    color: .pink,
                    level: 2,
                    isVisible: true,
                    displayOrder: 0,
                    parentId: fitnessId,
                    isExpanded: false,
                    childIds: []
                ),
                // Study Category
                CategoryData(
                    id: studyId,
                    name: "Study",
                    color: .brown,
                    level: 1,
                    isVisible: true,
                    displayOrder: 1,
                    parentId: personalId,
                    isExpanded: true,
                    childIds: [languageId]
                ),
                // Language Study
                CategoryData(
                    id: languageId,
                    name: "Language",
                    color: .yellow,
                    level: 2,
                    isVisible: true,
                    displayOrder: 0,
                    parentId: studyId,
                    isExpanded: false,
                    childIds: []
                )
            ]
        }()
    )
    .environmentObject(ThemeManager.shared)
}

#Preview("Empty State", traits: .sizeThatFitsLayout) {
    // Empty state
    SPCategoryList(categories: [])
        .environmentObject(ThemeManager.shared)
}

#Preview("Dark Mode", traits: .sizeThatFitsLayout) {
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
} 
