import Foundation
import OSLog

/// 日志类别
enum SPLogCategory: String {
    case coreData = "CoreData"
    case theme = "Theme"
    case network = "Network"
    case ui = "UI"
    case general = "General"
}

/// 日志级别
enum SPLogLevel: String {
    case trace = "🔍 TRACE"
    case debug = "🔍 DEBUG"
    case info = "ℹ️ INFO"
    case notice = "📢 NOTICE"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
    case fault = "💥 FAULT"
}

/// SmartPlanner 日志系统
final class SPLogger {
    
    // MARK: - Properties
    
    /// 共享实例
    static let shared = SPLogger()
    
    /// 系统日志器
    private let logger: Logger
    
    /// 文件日志URL
    private let fileURL: URL
    
    /// 日期格式器
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    /// 文件管理器
    private let fileManager = FileManager.default
    
    /// 日志队列
    private let logQueue = DispatchQueue(label: "com.smartplanner.logger", qos: .utility)
    
    // MARK: - Initialization
    
    private init() {
        // 初始化系统日志器
        logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "SmartPlanner",
                       category: "App")
        
        // 设置文件日志路径
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documentsPath.appendingPathComponent("SmartPlanner.log")
        
        // 创建日志文件
        createLogFileIfNeeded()
        
        // 清理旧日志
        cleanOldLogs()
    }
    
    // MARK: - Public Methods
    
    /// 记录追踪信息（仅在调试模式下记录）
    /// - Parameters:
    ///   - message: 日志消息
    ///   - category: 日志类别
    ///   - file: 源文件
    ///   - function: 函数名
    ///   - line: 行号
    func trace(_ message: String,
              category: SPLogCategory = .general,
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
        #if DEBUG
        log(message, level: .trace, category: category, file: file, function: function, line: line)
        #endif
    }
    
    /// 记录调试信息
    /// - Parameters:
    ///   - message: 日志消息
    ///   - category: 日志类别
    ///   - file: 源文件
    ///   - function: 函数名
    ///   - line: 行号
    func debug(_ message: String,
              category: SPLogCategory = .general,
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    /// 记录普通信息
    func info(_ message: String,
             category: SPLogCategory = .general,
             file: String = #file,
             function: String = #function,
             line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    /// 记录通知信息
    func notice(_ message: String,
               category: SPLogCategory = .general,
               file: String = #file,
               function: String = #function,
               line: Int = #line) {
        log(message, level: .notice, category: category, file: file, function: function, line: line)
    }
    
    /// 记录警告信息
    func warning(_ message: String,
                category: SPLogCategory = .general,
                file: String = #file,
                function: String = #function,
                line: Int = #line) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    /// 记录错误信息
    func error(_ message: String,
              category: SPLogCategory = .general,
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }
    
    /// 记录严重错误信息
    func fault(_ message: String,
              category: SPLogCategory = .general,
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
        log(message, level: .fault, category: category, file: file, function: function, line: line)
    }
    
    // MARK: - Private Methods
    
    /// 记录日志
    private func log(_ message: String,
                    level: SPLogLevel,
                    category: SPLogCategory,
                    file: String,
                    function: String,
                    line: Int) {
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        
        // 构建日志消息
        let logMessage = "\(timestamp) [\(category.rawValue)] \(level.rawValue): \(message) (\(fileName):\(line) \(function))"
        
        // 写入系统日志
        switch level {
        case .trace:
            logger.debug("\(logMessage)")
        case .debug:
            logger.debug("\(logMessage)")
        case .info:
            logger.info("\(logMessage)")
        case .notice:
            logger.notice("\(logMessage)")
        case .warning:
            logger.warning("\(logMessage)")
        case .error:
            logger.error("\(logMessage)")
        case .fault:
            logger.fault("\(logMessage)")
        }
        
        // 写入文件日志
        logQueue.async {
            self.writeToFile(logMessage)
        }
    }
    
    /// 写入文件日志
    private func writeToFile(_ message: String) {
        guard let data = (message + "\n").data(using: .utf8) else { return }
        
        if fileManager.fileExists(atPath: fileURL.path) {
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                try? fileHandle.close()
            }
        } else {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
    
    /// 创建日志文件
    private func createLogFileIfNeeded() {
        guard !fileManager.fileExists(atPath: fileURL.path) else { return }
        fileManager.createFile(atPath: fileURL.path, contents: nil)
    }
    
    /// 清理旧日志
    private func cleanOldLogs() {
        // 如果日志文件大于 10MB，清除一半内容
        guard let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
              let fileSize = attributes[.size] as? Int64,
              fileSize > 10 * 1024 * 1024 else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let halfData = data.suffix(Int(fileSize / 2))
            try halfData.write(to: fileURL, options: .atomic)
        } catch {
            print("清理日志失败: \(error.localizedDescription)")
        }
    }
}

// MARK: - Convenience Methods

extension SPLogger {
    /// 获取日志内容
    func getLogContent() -> String {
        (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
    }
    
    /// 清除所有日志
    func clearLogs() {
        try? fileManager.removeItem(at: fileURL)
        createLogFileIfNeeded()
    }
} 