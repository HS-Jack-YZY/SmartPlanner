import SwiftUI

/// Category item component
/// Displays category information including color indicator, name, and subcategory count
/// Supports drag and drop for category reordering and parent changes
struct SPCategoryItem: View {
    // MARK: - Environment
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Properties
    
    // Data properties
    let id: UUID
    let name: String
    let color: Color
    let level: Int16
    let isVisible: Bool
    let displayOrder: Int16
    let parentId: UUID?
    
    // UI states
    let isExpanded: Bool
    let showArrow: Bool
    let childCount: Int
    let isOverlapped: Bool
    
    // Drag and drop states
    @State private var isDragging: Bool = false
    @State private var dragOffset: CGSize = .zero
    @GestureState private var isLongPressed: Bool = false
    
    // Callbacks
    let onToggleExpand: (() -> Void)?
    let onSelect: (() -> Void)?
    let onDragStarted: ((UUID) -> Void)?
    let onDragChanged: ((UUID, CGPoint) -> Void)?
    let onDragEnded: ((UUID, CGPoint) -> Void)?
    
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
        static let overlapBackgroundOpacity: Double = 0.1
        
        // Animation constants
        static let dragScale: CGFloat = 1.05
        static let dragShadowRadius: CGFloat = 10
        static let dragShadowOpacity: Double = 0.2
        static let dragAnimationDuration: Double = 0.2
        static let dragZIndex: Double = 100
    }
    
    // MARK: - Dragging View
    
    /// View displayed while dragging a category
    private struct DraggingCategoryView: View {
        // MARK: - Environment
        
        @EnvironmentObject private var themeManager: ThemeManager
        
        // MARK: - Properties
        
        let name: String
        let color: Color
        let childCount: Int
        
        // MARK: - Body
        
        var body: some View {
            HStack(spacing: Layout.spacing) {
                // Color indicator
                Circle()
                    .fill(color)
                    .frame(width: Layout.colorIndicatorSize, height: Layout.colorIndicatorSize)
                
                // Category name
                Text(name)
                    .font(Layout.nameFont)
                    .foregroundColor(themeManager.getThemeColor(.primaryText))
                
                Spacer(minLength: Layout.spacing)
                
                // Child count
                if childCount > 0 {
                    Text("\(childCount)")
                        .font(Layout.countFont)
                        .foregroundColor(themeManager.getThemeColor(.secondaryText))
                        .frame(minWidth: 20)
                }
            }
            .frame(height: Layout.itemHeight)
            .padding(.horizontal, Layout.horizontalPadding)
            .background(themeManager.getThemeColor(.background))
            .scaleEffect(Layout.dragScale)
            .shadow(
                color: Color.black.opacity(Layout.dragShadowOpacity),
                radius: Layout.dragShadowRadius
            )
        }
    }
    
    // MARK: - Initialization
    
    /// Initialize category item
    /// - Parameters:
    ///   - id: Category unique identifier
    ///   - name: Category name
    ///   - color: Category color
    ///   - level: Hierarchy depth (0-5), 0 means root category
    ///   - isVisible: Whether the category is visible
    ///   - displayOrder: Display order (within same level, smaller value comes first)
    ///   - parentId: Parent category ID (nil for level 0)
    ///   - isExpanded: Whether subcategories are expanded
    ///   - showArrow: Whether to show expand/collapse arrow
    ///   - childCount: Number of subcategories
    ///   - isOverlapped: Whether the category is overlapped
    ///   - onToggleExpand: Expand/collapse callback
    ///   - onSelect: Selection callback
    ///   - onDragStarted: Called when drag gesture starts
    ///   - onDragChanged: Called when drag position changes
    ///   - onDragEnded: Called when drag gesture ends
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
        isOverlapped: Bool = false,
        onToggleExpand: (() -> Void)? = nil,
        onSelect: (() -> Void)? = nil,
        onDragStarted: ((UUID) -> Void)? = nil,
        onDragChanged: ((UUID, CGPoint) -> Void)? = nil,
        onDragEnded: ((UUID, CGPoint) -> Void)? = nil
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
        self.isOverlapped = isOverlapped
        self.onToggleExpand = onToggleExpand
        self.onSelect = onSelect
        self.onDragStarted = onDragStarted
        self.onDragChanged = onDragChanged
        self.onDragEnded = onDragEnded
    }
    
    // MARK: - Private Views
    
    /// Color indicator view
    private var colorIndicator: some View {
        Circle()
            .fill(color)
            .frame(width: Layout.colorIndicatorSize, height: Layout.colorIndicatorSize)
            .opacity(isVisible ? Layout.activeOpacity : Layout.inactiveOpacity)
            .accessibilityHidden(true)
    }
    
    /// Category name view
    private var nameLabel: some View {
        Text(name)
            .font(Layout.nameFont)
            .foregroundColor(themeManager.getThemeColor(.primaryText))
            .opacity(isVisible ? Layout.activeOpacity : Layout.inactiveOpacity)
            .accessibilityLabel(Text("Category: \(name)"))
            .accessibilityAddTraits(.isButton)
    }
    
    /// Subcategory count view
    private var childCountLabel: some View {
        Group {
            if childCount > 0 && !isExpanded {
                Text("\(childCount)")
                    .font(Layout.countFont)
                    .foregroundColor(themeManager.getThemeColor(.secondaryText))
                    .frame(minWidth: 20)
                    .opacity(isVisible ? Layout.activeOpacity : Layout.inactiveOpacity)
                    .accessibilityLabel(Text("Contains \(childCount) subcategories"))
            }
        }
    }
    
    /// Arrow icon view
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
                        withAnimation(.easeInOut(duration: Layout.dragAnimationDuration)) {
                            onToggleExpand?()
                        }
                    }
                    .accessibilityLabel(Text(isExpanded ? "Collapse" : "Expand"))
                    .accessibilityAddTraits(.isButton)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Handle drag start
    private func handleDragStart() {
        withAnimation(.easeInOut(duration: Layout.dragAnimationDuration)) {
            self.isDragging = true
            // Collapse if has children
            if childCount > 0 && isExpanded {
                onToggleExpand?()
            }
            self.onDragStarted?(self.id)
        }
    }
    
    // MARK: - Gesture Handlers
    
    /// Combined gesture for long press and drag
    private var dragGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .updating($isLongPressed) { value, state, _ in
                state = value
                if value {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }
            }
            .onEnded { _ in
                handleDragStart()
            }
            .sequenced(before: DragGesture(coordinateSpace: .global))
            .onChanged { value in
                switch value {
                case .first(true):
                    // Long press is active
                    break
                case .second(true, let drag):
                    self.dragOffset = drag?.translation ?? .zero
                    if let location = drag?.location {
                        self.onDragChanged?(self.id, location)
                    }
                default:
                    break
                }
            }
            .onEnded { value in
                switch value {
                case .second(true, let drag):
                    withAnimation(.easeInOut(duration: Layout.dragAnimationDuration)) {
                        self.isDragging = false
                        self.dragOffset = .zero
                        if let location = drag?.location {
                            self.onDragEnded?(self.id, location)
                        }
                    }
                default:
                    withAnimation(.easeInOut(duration: Layout.dragAnimationDuration)) {
                        self.isDragging = false
                        self.dragOffset = .zero
                    }
                }
            }
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if isDragging {
                DraggingCategoryView(
                    name: name,
                    color: color,
                    childCount: childCount
                )
                .offset(dragOffset)
                .zIndex(Layout.dragZIndex)
            } else {
                HStack(spacing: Layout.spacing) {
                    // Level indent space
                    if level > 0 {
                        Spacer()
                            .frame(width: CGFloat(level) * Layout.levelIndent)
                            .accessibilityHidden(true)
                    }
                    
                    // Color indicator
                    colorIndicator
                    
                    // Category name
                    nameLabel
                    
                    Spacer(minLength: Layout.spacing)
                    
                    // Subcategory count
                    childCountLabel
                    
                    // Arrow icon
                    arrowIcon
                }
                .frame(height: Layout.itemHeight)
                .padding(.horizontal, Layout.horizontalPadding)
                .background(
                    Group {
                        if isOverlapped {
                            color.opacity(Layout.overlapBackgroundOpacity)
                        } else {
                            themeManager.getThemeColor(.background)
                        }
                    }
                )
            }
        }
        .gesture(dragGesture)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect?()
        }
        .animation(.easeInOut(duration: Layout.dragAnimationDuration), value: isDragging)
        .animation(.easeInOut(duration: Layout.dragAnimationDuration), value: isOverlapped)
    }
}

// MARK: - Preview Provider

#Preview("Default State") {
    VStack(spacing: 0) {
        SPCategoryItem(
            id: UUID(),
            name: "Work",
            color: .blue,
            isExpanded: true,
            childCount: 3,
            onToggleExpand: {
                print("Toggle Work")
            },
            onSelect: {
                print("Select Work")
            },
            onDragStarted: { id in
                print("Start dragging \(id)")
            },
            onDragChanged: { id, location in
                print("Dragging \(id) at \(location)")
            },
            onDragEnded: { id, location in
                print("End dragging \(id) at \(location)")
            }
        )
        
        SPCategoryItem(
            id: UUID(),
            name: "Meetings",
            color: .purple,
            level: 1,
            displayOrder: 1,
            childCount: 2,
            onToggleExpand: {
                print("Toggle Meetings")
            },
            onSelect: {
                print("Select Meetings")
            }
        )
        
        SPCategoryItem(
            id: UUID(),
            name: "Weekly",
            color: .green,
            level: 2,
            displayOrder: 2,
            onSelect: {
                print("Select Weekly")
            }
        )
        
        SPCategoryItem(
            id: UUID(),
            name: "Break",
            color: .orange,
            isVisible: false,
            showArrow: false,
            onSelect: {
                print("Select Break")
            }
        )
    }
    .environmentObject(ThemeManager.shared)
}

#Preview("Dark Mode") {
    SPCategoryItem(
        id: UUID(),
        name: "Work",
        color: .blue,
        childCount: 3,
        onToggleExpand: {
            print("Toggle Work")
        },
        onSelect: {
            print("Select Work")
        }
    )
    .environmentObject(ThemeManager.shared)
    .preferredColorScheme(.dark)
} 
