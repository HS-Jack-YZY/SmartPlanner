import Foundation

/// 测试日志工具类
final class TestLogger {
    // MARK: - Properties
    
    /// 单例实例
    static let shared = TestLogger()
    
    /// 日志文件URL
    private let logFileURL: URL
    
    /// 日期格式器
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    /// 文件管理器
    private let fileManager = FileManager.default
    
    // MARK: - 日志级别
    
    enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        
        var prefix: String {
            "[\(rawValue)]"
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        // 获取应用支持目录
        let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let testLogsDirectory = applicationSupport.appendingPathComponent("SmartPlannerTests/Logs", isDirectory: true)
        
        // 创建日志目录
        try? fileManager.createDirectory(at: testLogsDirectory, withIntermediateDirectories: true)
        
        // 创建当前日期的日志文件
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        logFileURL = testLogsDirectory.appendingPathComponent("test_log_\(dateString).log")
        
        // 写入日志文件头
        let header = """
        =====================================
        SmartPlanner Tests Log
        开始时间: \(dateFormatter.string(from: Date()))
        =====================================\n\n
        """
        try? header.write(to: logFileURL, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Public Methods
    
    /// 写入日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - level: 日志级别
    ///   - file: 源文件
    ///   - function: 函数名
    ///   - line: 行号
    func log(
        _ message: String,
        level: LogLevel = .info,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let timestamp = dateFormatter.string(from: Date())
        let sourceFile = URL(fileURLWithPath: file).lastPathComponent
        
        let logMessage = "\(timestamp) \(level.prefix) [\(sourceFile):\(line) \(function)] \(message)\n"
        
        if let data = logMessage.data(using: .utf8) {
            if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        }
        
        // 在调试模式下同时打印到控制台
        #if DEBUG
        print(logMessage, terminator: "")
        #endif
    }
    
    /// 记录测试开始
    /// - Parameters:
    ///   - testName: 测试名称
    ///   - file: 源文件
    ///   - function: 函数名
    func logTestStart(
        _ testName: String,
        file: String = #file,
        function: String = #function
    ) {
        log("=== 测试开始: \(testName) ===", level: .info, file: file, function: function)
    }
    
    /// 记录测试结束
    /// - Parameters:
    ///   - testName: 测试名称
    ///   - file: 源文件
    ///   - function: 函数名
    func logTestEnd(
        _ testName: String,
        file: String = #file,
        function: String = #function
    ) {
        log("=== 测试结束: \(testName) ===\n", level: .info, file: file, function: function)
    }
    
    /// 记录错误
    /// - Parameters:
    ///   - error: 错误对象
    ///   - file: 源文件
    ///   - function: 函数名
    ///   - line: 行号
    func logError(
        _ error: Error,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log("错误: \(error.localizedDescription)", level: .error, file: file, function: function, line: line)
    }
} 