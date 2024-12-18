import Foundation
import Combine

enum Language: String, CaseIterable {
    case system = "system"  // 跟随系统
    case zhHans = "zh-Hans" // 简体中文
    case zhHant = "zh-Hant" // 繁体中文
    case en = "en"         // 英语
    
    var displayName: String {
        switch self {
        case .system:
            return "跟随系统"
        case .zhHans:
            return "简体中文"
        case .zhHant:
            return "繁体中文"
        case .en:
            return "English"
        }
    }
}

final class LanguageManager: ObservableObject {
    // MARK: - Properties
    
    static let shared = LanguageManager()
    
    @Published private(set) var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "AppLanguage")
            updateLocale()
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        // 从 UserDefaults 读取保存的语言设置，默认跟随系统
        let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") ?? Language.system.rawValue
        self.currentLanguage = Language(rawValue: savedLanguage) ?? .system
        
        // 设置初始区域设置
        updateLocale()
        
        // 监听系统语言变化
        NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)
            .sink { [weak self] _ in
                self?.updateLocale()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// 设置应用语言
    func setLanguage(_ language: Language) {
        guard language != currentLanguage else { return }
        currentLanguage = language
    }
    
    /// 获取本地化字符串
    func localizedString(_ key: String, comment: String = "") -> String {
        let language = currentLanguage == .system ? Locale.current.language.languageCode?.identifier ?? "en" : currentLanguage.rawValue
        
        // 尝试从指定语言的本地化文件中获取字符串
        if let languagePath = Bundle.main.path(forResource: language, ofType: "lproj"),
           let languageBundle = Bundle(path: languagePath) {
            return languageBundle.localizedString(forKey: key, value: nil, table: nil)
        }
        
        // 如果找不到对应的语言文件，返回英文
        return Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    }
    
    // MARK: - Private Methods
    
    private func updateLocale() {
        // 根据当前语言设置更新区域设置
        let identifier: String
        switch currentLanguage {
        case .system:
            identifier = Locale.current.identifier
        case .zhHans:
            identifier = "zh_CN"
        case .zhHant:
            identifier = "zh_TW"
        case .en:
            identifier = "en_US"
        }
        
        // 更新日期格式器的区域设置
        var newCalendar = DateHelper.calendar
        newCalendar.locale = Locale(identifier: identifier)
        DateHelper.calendar = newCalendar
    }
}

// MARK: - Convenience Extensions

extension String {
    /// 获取本地化字符串的便捷方法
    var localized: String {
        LanguageManager.shared.localizedString(self)
    }
} 