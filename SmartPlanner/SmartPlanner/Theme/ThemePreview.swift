import SwiftUI

struct ThemePreview: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationView {
            List {
                // 主题选择器
                Section(header: Text("主题设置").textCase(.none)) {
                    ThemeSelector()
                }
                
                // 颜色预览
                Section(header: Text("颜色预览").textCase(.none)) {
                    ColorPreviewGroup()
                }
                
                // 字体预览
                Section(header: Text("字体预览").textCase(.none)) {
                    FontPreviewGroup()
                }
            }
            .navigationTitle("主题预览")
            .navigationBarTitleDisplayMode(.inline)
        }
        .environmentObject(themeManager)
    }
}

// MARK: - Theme Selector

private struct ThemeSelector: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedTheme: ThemeType
    
    init() {
        _selectedTheme = State(initialValue: ThemeManager.shared.currentTheme)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Picker("主题模式", selection: $selectedTheme) {
                Text("跟随系统").tag(ThemeType.system)
                Text("浅色模式").tag(ThemeType.light)
                Text("深色模式").tag(ThemeType.dark)
                Text("自定义主题").tag(ThemeType.custom)
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedTheme) { newValue in
                withAnimation {
                    themeManager.setTheme(newValue)
                }
            }
        }
    }
}

// MARK: - Color Preview

private struct ColorPreviewGroup: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            ColorGroup(title: "主要颜色") {
                ColorGrid {
                    ColorPreviewItem(title: "主题色",
                                   color: themeManager.getThemeColor(.primary),
                                   key: .primary)
                    ColorPreviewItem(title: "次要主题色",
                                   color: themeManager.getThemeColor(.secondary),
                                   key: .secondary)
                }
            }
            
            ColorGroup(title: "背景颜色") {
                ColorGrid {
                    ColorPreviewItem(title: "背景色",
                                   color: themeManager.getThemeColor(.background),
                                   key: .background)
                    ColorPreviewItem(title: "次要背景色",
                                   color: themeManager.getThemeColor(.secondaryBackground),
                                   key: .secondaryBackground)
                }
            }
            
            ColorGroup(title: "文本颜色") {
                ColorGrid {
                    ColorPreviewItem(title: "主要文本色",
                                   color: themeManager.getThemeColor(.primaryText),
                                   key: .primaryText)
                    ColorPreviewItem(title: "次要文本色",
                                   color: themeManager.getThemeColor(.secondaryText),
                                   key: .secondaryText)
                }
            }
            
            ColorGroup(title: "区间颜色") {
                ColorGrid {
                    ColorPreviewItem(title: "工作区间色",
                                   color: themeManager.getThemeColor(.workBlock),
                                   key: .workBlock)
                    ColorPreviewItem(title: "个人区间色",
                                   color: themeManager.getThemeColor(.personalBlock),
                                   key: .personalBlock)
                }
            }
            
            ColorGroup(title: "状态颜色") {
                ColorGrid {
                    ColorPreviewItem(title: "成功状态色",
                                   color: themeManager.getThemeColor(.success),
                                   key: .success)
                    ColorPreviewItem(title: "警告状态色",
                                   color: themeManager.getThemeColor(.warning),
                                   key: .warning)
                    ColorPreviewItem(title: "错误状态色",
                                   color: themeManager.getThemeColor(.error),
                                   key: .error)
                }
            }
        }
    }
}

private struct ColorGrid<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            content
        }
    }
}

private struct ColorPreviewItem: View {
    let title: String
    let color: Color
    let key: ColorKey
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Font Preview

private struct FontPreviewGroup: View {
    var body: some View {
        VStack(spacing: 16) {
            Group {
                FontPreviewItem(title: "大标题", font: FontTheme.largeTitle)
                FontPreviewItem(title: "标题1", font: FontTheme.title1)
                FontPreviewItem(title: "标题2", font: FontTheme.title2)
                FontPreviewItem(title: "标题3", font: FontTheme.title3)
                FontPreviewItem(title: "正文", font: FontTheme.body)
            }
            
            Group {
                FontPreviewItem(title: "标注", font: FontTheme.callout)
                FontPreviewItem(title: "副标题", font: FontTheme.subheadline)
                FontPreviewItem(title: "脚注", font: FontTheme.footnote)
                FontPreviewItem(title: "数字", font: FontTheme.number)
                FontPreviewItem(title: "强调", font: FontTheme.emphasized)
            }
        }
    }
}

private struct FontPreviewItem: View {
    let title: String
    let font: Font
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text("智能日程规划示例")
                .font(font)
                .lineLimit(1)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Helper Views

private struct ColorGroup<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            content
        }
    }
}

// MARK: - Previews

struct ThemePreview_Previews: PreviewProvider {
    static var previews: some View {
        ThemePreview()
            .environmentObject(ThemeManager.shared)
    }
} 