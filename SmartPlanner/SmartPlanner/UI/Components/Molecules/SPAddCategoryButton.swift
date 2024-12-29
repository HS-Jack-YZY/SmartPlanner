import SwiftUI

/// 添加类别按钮组件
/// 用于快速添加新类别
struct SPAddCategoryButton: View {
    // MARK: - Environment
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    // MARK: - Properties
    
    /// 点击回调
    let onTap: (() -> Void)?
    
    // MARK: - Layout Constants
    
    private enum Layout {
        static let height: CGFloat = 44
        static let iconSize: CGFloat = 22
        static let spacing: CGFloat = 8
        static let horizontalPadding: CGFloat = 16
    }
    
    // MARK: - Initialization
    
    init(onTap: (() -> Void)? = nil) {
        self.onTap = onTap
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(spacing: Layout.spacing) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: Layout.iconSize))
                
                Text("Add Category")
                    .font(.system(size: 17, weight: .regular))
                
                Spacer()
            }
            .foregroundColor(themeManager.getThemeColor(.primary))
            .frame(height: Layout.height)
            .padding(.horizontal, Layout.horizontalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Add new category")
    }
}

// MARK: - Preview Provider

struct SPAddCategoryButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 浅色模式
            SPAddCategoryButton {
                print("Add category tapped")
            }
            .environmentObject(ThemeManager.shared)
            .previewDisplayName("浅色模式")
            
            // 深色模式
            SPAddCategoryButton {
                print("Add category tapped")
            }
            .environmentObject(ThemeManager.shared)
            .preferredColorScheme(.dark)
            .previewDisplayName("深色模式")
        }
        .previewLayout(.sizeThatFits)
        .background(Color(.systemBackground))
    }
} 