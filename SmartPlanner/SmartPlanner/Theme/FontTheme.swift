import SwiftUI

/// 字体主题枚举
/// 提供应用程序所需的所有字体样式
/// 支持动态字体大小调整
enum FontTheme {
    // MARK: - 标题字体
    
    /// 大标题字体，用于页面主标题
    static let largeTitle = Font.system(.largeTitle, design: .rounded)
    /// 标题1字体，用于重要区域标题
    static let title1 = Font.system(.title, design: .rounded)
    /// 标题2字体，用于次要区域标题
    static let title2 = Font.system(.title2, design: .rounded)
    /// 标题3字体，用于小标题
    static let title3 = Font.system(.title3, design: .rounded)
    
    // MARK: - 正文字体
    
    /// 正文字体，用于普通文本
    static let body = Font.system(.body)
    /// 标注字体，用于重要说明
    static let callout = Font.system(.callout)
    /// 副标题字体，用于辅助说明
    static let subheadline = Font.system(.subheadline)
    /// 脚注字体，用于次要信息
    static let footnote = Font.system(.footnote)
    
    // MARK: - 特殊字体
    
    /// 数字字体，等宽字体便于对齐
    static let number = Font.system(.body, design: .monospaced)
    /// 强调字体，用于重要文本
    static let emphasized = Font.system(.body, design: .rounded).bold()
} 