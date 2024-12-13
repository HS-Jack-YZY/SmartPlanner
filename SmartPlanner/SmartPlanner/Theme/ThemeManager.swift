import SwiftUI
import Combine

/// 主题管理器
/// 负责管理应用程序的主题状态和切换
final class ThemeManager: ObservableObject {
    // MARK: - Singleton
    
    /// 共享实例
    static let shared = ThemeManager()
    
    // MARK: - Published Properties
    
    /// 深色模式状态
    @Published private(set) var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: UserDefaultsKeys.isDarkMode)
            updateAppearance()
        }
    }
    
    // MARK: - Private Properties
    
    /// UserDefaults键值常量
    private enum UserDefaultsKeys {
        static let isDarkMode = "isDarkMode"
    }
    
    // MARK: - Initialization
    
    private init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isDarkMode)
    }
    
    // MARK: - Private Methods
    
    /// 更新系统外观
    private func updateAppearance() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            assertionFailure("无法获取windowScene")
            return
        }
        
        windowScene.windows.forEach { window in
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }
    
    // MARK: - Public Methods
    
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
} 