import SwiftUI

struct ThemePreview: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        List {
            // MARK: - 颜色预览
            Section("颜色主题") {
                ColorRow(title: "主题色", color: ColorTheme.primary)
                ColorRow(title: "次要主题色", color: ColorTheme.secondary)
                ColorRow(title: "背景色", color: ColorTheme.background)
                ColorRow(title: "次要背景色", color: ColorTheme.secondaryBackground)
                ColorRow(title: "主要文本色", color: ColorTheme.primaryText)
                ColorRow(title: "次要文本色", color: ColorTheme.secondaryText)
                ColorRow(title: "工作区间色", color: ColorTheme.workBlock)
                ColorRow(title: "个人区间色", color: ColorTheme.personalBlock)
                ColorRow(title: "成功状态色", color: ColorTheme.success)
                ColorRow(title: "警告状态色", color: ColorTheme.warning)
                ColorRow(title: "错误状态色", color: ColorTheme.error)
            }
            
            // MARK: - 字体预览
            Section("字体主题") {
                FontRow(title: "大标题", font: FontTheme.largeTitle)
                FontRow(title: "标题1", font: FontTheme.title1)
                FontRow(title: "标题2", font: FontTheme.title2)
                FontRow(title: "标题3", font: FontTheme.title3)
                FontRow(title: "正文", font: FontTheme.body)
                FontRow(title: "标注", font: FontTheme.callout)
                FontRow(title: "副标题", font: FontTheme.subheadline)
                FontRow(title: "脚注", font: FontTheme.footnote)
                FontRow(title: "数字", font: FontTheme.number)
                FontRow(title: "强调", font: FontTheme.emphasized)
            }
            
            // MARK: - 主题切换
            Section {
                Toggle("深色模式", isOn: Binding(
                    get: { themeManager.isDarkMode },
                    set: { themeManager.setDarkMode($0) }
                ))
            }
        }
        .navigationTitle("主题预览")
    }
}

// MARK: - 辅助视图

private struct ColorRow: View {
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            RoundedRectangle(cornerRadius: 6)
                .fill(color)
                .frame(width: 30, height: 30)
        }
    }
}

private struct FontRow: View {
    let title: String
    let font: Font
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("示例文本")
                .font(font)
        }
    }
}

// MARK: - 预览
struct ThemePreview_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ThemePreview()
        }
    }
} 