import SwiftUI
import Combine

/// 主题类型
enum ThemeType: String, Codable {
    case system   // 跟随系统
    case light    // 浅色主题
    case dark     // 深色主题
    case custom   // 自定义主题
}

/// 颜色键名
enum ColorKey: String {
    // 主要颜色
    case primary = "AppPrimaryColor"
    case secondary = "AppSecondaryColor"
    
    // 背景颜色
    case background = "BackgroundColor"
    case secondaryBackground = "SecondaryBackgroundColor"
    
    // 文本颜色
    case primaryText = "PrimaryTextColor"
    case secondaryText = "SecondaryTextColor"
    
    // 区间颜色
    case workBlock = "WorkBlockColor"
    case personalBlock = "PersonalBlockColor"
    
    // 状态颜色
    case success = "SuccessColor"
    case warning = "WarningColor"
    case error = "ErrorColor"
    
    /// 获取颜色
    var color: Color {
        Color(rawValue, bundle: .main)
    }
    
    /// 获取自定义颜色名称
    var customName: String {
        "Custom\(rawValue)"
    }
    
    /// 获取自定义颜色
    var customColor: Color {
        Color(customName, bundle: .main)
    }
}

/// 主题管理器
/// 负责管理应用程序的主题状态和切换
final class ThemeManager: ObservableObject {
    // MARK: - Singleton
    
    /// 共享实例
    static let shared = ThemeManager()
    
    // MARK: - Published Properties
    
    /// 当前主题类型
    @Published private(set) var currentTheme: ThemeType {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: UserDefaultsKeys.themeType)
            updateAppearance()
        }
    }
    
    /// 深色模式状态
    @Published private(set) var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: UserDefaultsKeys.isDarkMode)
            if currentTheme != .system {
                updateAppearance()
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var themeUpdateCancellable: AnyCancellable?
    
    /// UserDefaults键值常量
    private enum UserDefaultsKeys {
        static let themeType = "themeType"
        static let isDarkMode = "isDarkMode"
    }
    
    // MARK: - Initialization
    
    private init() {
        // 初始化主题类型
        let savedThemeType = UserDefaults.standard.string(forKey: UserDefaultsKeys.themeType)
        self.currentTheme = ThemeType(rawValue: savedThemeType ?? "") ?? .system
        
        // 初始化深色模式状态
        self.isDarkMode = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isDarkMode)
        
        // 监听系统外观变化
        if currentTheme == .system {
            setupSystemThemeObserver()
        }
    }
    
    // MARK: - Private Methods
    
    /// 设置系统主题观察者
    private func setupSystemThemeObserver() {
        themeUpdateCancellable = NotificationCenter.default.publisher(
            for: UIApplication.didBecomeActiveNotification
        )
        .sink { [weak self] _ in
            self?.updateSystemTheme()
        }
    }
    
    /// 更新系统主题
    private func updateSystemTheme() {
        if currentTheme == .system {
            let isDark = UITraitCollection.current.userInterfaceStyle == .dark
            if isDark != isDarkMode {
                isDarkMode = isDark
                updateAppearance()
            }
        }
    }
    
    /// 更新系统外观
    private func updateAppearance() {
        withAnimation(.easeInOut(duration: 0.3)) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                assertionFailure("无法获取windowScene")
                return
            }
            
            let style: UIUserInterfaceStyle = {
                switch currentTheme {
                case .system:
                    return UITraitCollection.current.userInterfaceStyle
                case .light:
                    return .light
                case .dark:
                    return .dark
                case .custom:
                    return isDarkMode ? .dark : .light
                }
            }()
            
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = style
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// 设置主题类型
    /// - Parameter type: 主题类型
    func setTheme(_ type: ThemeType) {
        guard type != currentTheme else { return }
        currentTheme = type
        
        if type == .system {
            setupSystemThemeObserver()
            updateSystemTheme()
        } else {
            themeUpdateCancellable?.cancel()
        }
    }
    
    /// 切换深色/浅色模式
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
    
    /// 设置深色模式状态
    /// - Parameter isDark: 是否启用深色模式
    func setDarkMode(_ isDark: Bool) {
        guard isDark != isDarkMode else { return }
        isDarkMode = isDark
    }
    
    /// 获取主题颜色
    /// - Parameter key: 颜色键名
    /// - Returns: 对应的颜色
    func getThemeColor(_ key: ColorKey) -> Color {
        switch currentTheme {
        case .custom:
            return key.customColor
        default:
            return key.color
        }
    }
} 