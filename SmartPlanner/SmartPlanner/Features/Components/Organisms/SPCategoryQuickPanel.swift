import SwiftUI

/// 计划类别快捷面板
/// 提供快速访问计划类别的底部面板界面
struct SPCategoryQuickPanel: View {
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    // 面板尺寸常量
    private let panelHeight: CGFloat
    private let dragHandleWidth: CGFloat = 36
    private let dragHandleHeight: CGFloat = 5
    private let topCornerRadius: CGFloat = 13
    
    // 手势阈值常量
    private let dragThreshold: CGFloat = 20
    private let velocityThreshold: CGFloat = 300
    private let dismissThresholdPercentage: CGFloat = 0.3
    
    // MARK: - Initialization
    
    init(screenHeight: CGFloat) {
        self.panelHeight = screenHeight / 3
    }
    
    // MARK: - Private Views
    
    /// 拖动条视图
    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: dragHandleHeight / 2)
            .fill(themeManager.getThemeColor(.secondaryText).opacity(0.3))
            .frame(width: dragHandleWidth, height: dragHandleHeight)
            .padding(.vertical, 8)
    }
    
    /// 列表区域视图
    private var listArea: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // TODO: 添加类别列表项
                // 等待数据管理服务实现后添加
            }
        }
    }
    
    /// 新增按钮视图
    private var addButton: some View {
        Button(action: {
            // TODO: 实现新增类别功能
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .imageScale(.medium)
                Text("新增类别")
                    .font(.system(.body))
                Spacer()
            }
            .foregroundColor(themeManager.getThemeColor(.primary))
            .padding(.horizontal, 16)
            .frame(height: 44)
        }
    }
    
    // MARK: - Gesture Handlers
    
    /// 处理拖动手势
    private func handleDrag(translation: CGFloat) {
        let newOffset = translation
        
        // 限制上下拖动范围
        if newOffset < 0 {
            // 向上拖动，最多展开到全屏
            dragOffset = max(newOffset, -panelHeight)
        } else {
            // 向下拖动，最多隐藏面板
            dragOffset = min(newOffset, panelHeight)
        }
    }
    
    /// 处理拖动结束
    private func handleDragEnd(translation: CGFloat, velocity: CGFloat) {
        let translationAmount = abs(translation)
        let velocityAmount = abs(velocity)
        
        // 判断是否达到关闭或全屏阈值
        if translation > 0 { // 下滑
            if velocityAmount > velocityThreshold || translationAmount > panelHeight * dismissThresholdPercentage {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    dismiss()
                }
            } else {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    dragOffset = 0
                }
            }
        } else { // 上滑
            if velocityAmount > velocityThreshold || translationAmount > panelHeight * dismissThresholdPercentage {
                // TODO: 实现转场到全屏详细视图
            } else {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    dragOffset = 0
                }
            }
        }
        
        isDragging = false
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 拖动条
            dragHandle
            
            // 列表区域
            listArea
            
            // 分隔线
            Divider()
            
            // 新增按钮
            addButton
            
            // 底部安全区域
            Color.clear
                .frame(height: UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
        }
        .frame(height: panelHeight)
        .background(
            themeManager.getThemeColor(.background)
                .opacity(isDragging ? 0.95 : 1.0)
        )
        .clipShape(
            RoundedCorner(
                radius: topCornerRadius,
                corners: [.topLeft, .topRight]
            )
        )
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 10,
            x: 0,
            y: -2
        )
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    isDragging = true
                    handleDrag(translation: gesture.translation.height)
                }
                .onEnded { gesture in
                    handleDragEnd(
                        translation: gesture.translation.height,
                        velocity: gesture.velocity.height
                    )
                }
        )
    }
}

// MARK: - Helper Views

/// 自定义圆角形状
private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview {
    SPCategoryQuickPanel(screenHeight: UIScreen.main.bounds.height)
        .environmentObject(ThemeManager.shared)
} 