import SwiftUI

/// 可拖动手柄组件
/// 提供视觉拖动指示器和手势处理
struct SPDragHandle: View {
    // MARK: - Environment
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Properties
    
    /// 拖动回调，返回拖动距离
    let onDrag: ((CGFloat) -> Void)?
    /// 拖动结束回调，返回最终速度和距离
    let onDragEnd: ((CGFloat, CGFloat) -> Void)?
    /// 是否启用触感反馈
    let enableHaptics: Bool
    
    // MARK: - Layout Constants
    
    private enum Layout {
        static let width: CGFloat = 36
        static let height: CGFloat = 5
        static let cornerRadius: CGFloat = 2.5
        static let verticalPadding: CGFloat = 8
        static let tapArea: CGFloat = 44
        
        static let dragThreshold: CGFloat = 20
        static let velocityThreshold: CGFloat = 300
        static let dismissThreshold: CGFloat = 0.3
        
        static let activeOpacity: Double = 0.3
        static let inactiveOpacity: Double = 0.2
    }
    
    // MARK: - State
    
    @State private var isDragging: Bool = false
    @State private var dragOffset: CGFloat = 0
    
    // MARK: - Initialization
    
    init(
        onDrag: ((CGFloat) -> Void)? = nil,
        onDragEnd: ((CGFloat, CGFloat) -> Void)? = nil,
        enableHaptics: Bool = true
    ) {
        self.onDrag = onDrag
        self.onDragEnd = onDragEnd
        self.enableHaptics = enableHaptics
    }
    
    // MARK: - Private Methods
    
    /// 提供触感反馈
    private func generateHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard enableHaptics else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // MARK: - Gesture Handlers
    
    /// 处理拖动手势
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: Layout.dragThreshold)
            .onChanged { value in
                let translation = value.translation.height
                
                // 首次超过阈值时触发反馈
                if !isDragging && abs(translation) > Layout.dragThreshold {
                    isDragging = true
                    generateHapticFeedback(.light)
                }
                
                dragOffset = translation
                onDrag?(translation)
                
                // 超过解除阈值时触发反馈
                if abs(translation) > UIScreen.main.bounds.height * Layout.dismissThreshold {
                    generateHapticFeedback(.medium)
                }
            }
            .onEnded { value in
                isDragging = false
                dragOffset = 0
                
                let velocity = value.predictedEndLocation.y - value.location.y
                onDragEnd?(velocity, value.translation.height)
                
                // 根据结果触发不同的反馈
                if abs(velocity) > Layout.velocityThreshold {
                    generateHapticFeedback(.rigid)
                } else {
                    generateHapticFeedback(.soft)
                }
            }
    }
    
    // MARK: - Body
    
    var body: some View {
        // 拖动手柄视觉指示器
        RoundedRectangle(cornerRadius: Layout.cornerRadius)
            .fill(Color(.tertiaryLabel))
            .frame(width: Layout.width, height: Layout.height)
            .opacity(isDragging ? Layout.activeOpacity : Layout.inactiveOpacity)
            .padding(.vertical, Layout.verticalPadding)
            // 扩大点击区域
            .frame(height: Layout.tapArea)
            .contentShape(Rectangle())
            // 添加手势
            .gesture(dragGesture)
            // 添加无障碍支持
            .accessibilityLabel("Drag handle")
            .accessibilityHint("Drag up or down to expand or close panel")
            .accessibilityAddTraits(.allowsDirectInteraction)
    }
}

// MARK: - Preview Provider

struct SPDragHandle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SPDragHandle { translation in
                print("Dragging: \(translation)")
            } onDragEnd: { velocity, distance in
                print("Drag ended with velocity: \(velocity), distance: \(distance)")
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .environmentObject(ThemeManager.shared)
        .previewDisplayName("默认状态")
        
        VStack {
            SPDragHandle(enableHaptics: false)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .environmentObject(ThemeManager.shared)
        .preferredColorScheme(.dark)
        .previewDisplayName("深色模式")
    }
}