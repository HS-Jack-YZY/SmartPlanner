import SwiftUI

/// 颜色主题枚举
/// 提供应用程序所需的所有颜色常量
/// 支持深色模式和浅色模式
enum ColorTheme {
    // MARK: - 主要颜色
    
    /// 主题色，用于重要按钮和强调显示
    static let primary = Color("PrimaryColor")
    /// 次要主题色，用于次要按钮和辅助显示
    static let secondary = Color("SecondaryColor")
    
    // MARK: - 背景颜色
    
    /// 主背景色
    static let background = Color("BackgroundColor")
    /// 次要背景色，用于卡片、列表项等
    static let secondaryBackground = Color("SecondaryBackgroundColor")
    
    // MARK: - 文本颜色
    
    /// 主要文本颜色
    static let primaryText = Color("PrimaryTextColor")
    /// 次要文本颜色，用于说明文字等
    static let secondaryText = Color("SecondaryTextColor")
    
    // MARK: - 计划区间颜色
    
    /// 工作区间颜色
    static let workBlock = Color("WorkBlockColor")
    /// 个人区间颜色
    static let personalBlock = Color("PersonalBlockColor")
    
    // MARK: - 状态颜色
    
    /// 成功状态颜色
    static let success = Color("SuccessColor")
    /// 警告状态颜色
    static let warning = Color("WarningColor")
    /// 错误状态颜色
    static let error = Color("ErrorColor")
} 