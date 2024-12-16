import XCTest
@testable import SmartPlanner

final class ThemeTests: XCTestCase {
    // MARK: - Properties
    
    private var themeManager: ThemeManager!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        themeManager = ThemeManager.shared
    }
    
    override func tearDown() {
        themeManager = nil
        super.tearDown()
    }
    
    // MARK: - Theme Manager Tests
    
    func testThemeManagerInitialization() {
        XCTAssertNotNil(themeManager, "ThemeManager should be initialized")
    }
    
    func testDarkModeToggle() {
        let initialState = themeManager.isDarkMode
        themeManager.toggleDarkMode()
        XCTAssertEqual(themeManager.isDarkMode, !initialState, "Dark mode should be toggled")
    }
    
    func testSetDarkMode() {
        themeManager.setDarkMode(true)
        XCTAssertTrue(themeManager.isDarkMode, "Dark mode should be enabled")
        
        themeManager.setDarkMode(false)
        XCTAssertFalse(themeManager.isDarkMode, "Dark mode should be disabled")
    }
    
    func testDarkModePersistence() {
        let newValue = !themeManager.isDarkMode
        themeManager.setDarkMode(newValue)
        
        // 创建新实例验证持久化
        let newManager = ThemeManager.shared
        XCTAssertEqual(newManager.isDarkMode, newValue, "Dark mode state should persist")
    }
} 