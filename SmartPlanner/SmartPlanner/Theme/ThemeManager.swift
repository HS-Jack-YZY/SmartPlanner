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
    // MARK: - Properties
    
    /// 日志管理器
    private let logger = SPLogger.shared
    
    /// 取消令牌存储
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published Properties
    
    /// 当前主题类型
    @Published private(set) var currentTheme: ThemeType
    
    /// 深色模式状态
    @Published private(set) var isDarkMode: Bool
    
    // MARK: - Private Properties
    
    /// 主题更新观察者
    private var themeUpdateCancellable: AnyCancellable?
    
    /// UserDefaults键值常量
    private enum UserDefaultsKeys {
        static let themeType = "themeType"
        static let isDarkMode = "isDarkMode"
    }
    
    // MARK: - Singleton
    
    /// 共享实例
    static let shared = ThemeManager()
    
    // MARK: - Initialization
    
    private init() {
        // 第一阶段：初始化存储属性
        let savedThemeType = UserDefaults.standard.string(forKey: UserDefaultsKeys.themeType)
        self.currentTheme = ThemeType(rawValue: savedThemeType ?? "") ?? .system
        self.isDarkMode = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isDarkMode)
        
        // 第二阶段：设置和配置
        logger.info("初始化 ThemeManager", category: .theme)
        logger.debug("加载保存的主题类型: \(currentTheme.rawValue)", category: .theme)
        logger.debug("加载保存的深色模式状态: \(isDarkMode ? "开启" : "关闭")", category: .theme)
        
        // 设置属性观察器
        setupPropertyObservers()
        
        // 如果是系统主题，设置系统主题观察者
        if currentTheme == .system {
            setupSystemThemeObserver()
        }
    }
    
    // MARK: - Private Methods
    
    /// 设置属性观察器
    private func setupPropertyObservers() {
        $currentTheme
            .dropFirst()
            .sink { [weak self] newTheme in
                self?.logger.info("主题类型已更新: \(newTheme.rawValue)", category: .theme)
                UserDefaults.standard.set(newTheme.rawValue, forKey: UserDefaultsKeys.themeType)
                
                if newTheme == .system {
                    self?.setupSystemThemeObserver()
                } else {
                    self?.themeUpdateCancellable?.cancel()
                    self?.logger.debug("已取消系统主题观察者", category: .theme)
                }
                
                self?.updateAppearance()
            }
            .store(in: &cancellables)
        
        $isDarkMode
            .dropFirst()
            .sink { [weak self] isDark in
                self?.logger.info("深色模式状态已更新: \(isDark ? "开启" : "关闭")", category: .theme)
                UserDefaults.standard.set(isDark, forKey: UserDefaultsKeys.isDarkMode)
                if self?.currentTheme != .system {
                    self?.updateAppearance()
                }
            }
            .store(in: &cancellables)
    }
    
    /// 设置系统主题观察者
    private func setupSystemThemeObserver() {
        logger.debug("设置系统主题观察者", category: .theme)
        themeUpdateCancellable = NotificationCenter.default.publisher(
            for: UIApplication.didBecomeActiveNotification
        )
        .sink { [weak self] _ in
            self?.updateSystemTheme()
        }
    }
    
    /// 更新系统主题
    private func updateSystemTheme() {
        logger.debug("更新系统主题", category: .theme)
        if currentTheme == .system {
            let isDark = UITraitCollection.current.userInterfaceStyle == .dark
            if isDark != isDarkMode {
                isDarkMode = isDark
                updateAppearance()
                logger.info("系统主题已更新: \(isDark ? "深色" : "浅色")", category: .theme)
            }
        }
    }
    
    /// 更新系统外观
    private func updateAppearance() {
        logger.debug("更新系统外观", category: .theme)
        withAnimation(.easeInOut(duration: 0.3)) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                logger.error("无法获取windowScene", category: .theme)
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
            
            logger.info("系统外观已更新: \(style == .dark ? "深色" : "浅色")", category: .theme)
        }
    }
    
    // MARK: - Public Methods
    
    /// 设置主题类型
    /// - Parameter type: 主题类型
    func setTheme(_ type: ThemeType) {
        logger.debug("设置主题类型: \(type.rawValue)", category: .theme)
        guard type != currentTheme else {
            logger.debug("主题类型未变化，无需更新", category: .theme)
            return
        }
        currentTheme = type
    }
    
    /// 切换深色/浅色模式
    func toggleDarkMode() {
        logger.debug("切换深色/浅色模式", category: .theme)
        isDarkMode.toggle()
    }
    
    /// 设置深色模式状态
    /// - Parameter isDark: 是否启用深色模式
    func setDarkMode(_ isDark: Bool) {
        logger.debug("设置深色模式状态: \(isDark ? "开启" : "关闭")", category: .theme)
        guard isDark != isDarkMode else {
            logger.debug("深色模式状态未变化，无需更新", category: .theme)
            return
        }
        isDarkMode = isDark
    }
    
    /// 获取主题颜色
    /// - Parameter key: 颜色键名
    /// - Returns: 对应的颜色
    func getThemeColor(_ key: ColorKey) -> Color {
        logger.trace("获取主题颜色: \(key.rawValue)", category: .theme)
        switch currentTheme {
        case .custom:
            return key.customColor
        default:
            return key.color
        }
    }
} 