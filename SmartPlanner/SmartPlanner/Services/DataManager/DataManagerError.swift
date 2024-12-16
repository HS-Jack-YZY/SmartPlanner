import Foundation

/// 数据管理错误类型
enum DataManagerError: LocalizedError {
    case invalidEntity
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case invalidData
    case contextError
    case migrationFailed(Error)
    case migrationRequired
    case storeError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidEntity:
            return "无效的实体对象"
        case .saveFailed(let error):
            return "保存失败: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "获取失败: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "删除失败: \(error.localizedDescription)"
        case .invalidData:
            return "无效的数据"
        case .contextError:
            return "上下文错误"
        case .migrationFailed(let error):
            return "数据迁移失败: \(error.localizedDescription)"
        case .migrationRequired:
            return "需要进行数据迁移"
        case .storeError(let error):
            return "存储错误: \(error.localizedDescription)"
        case .unknown(let error):
            return "未知错误: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .migrationFailed:
            return "请尝试重新启动应用。如果问题持续存在，可能需要重新安装应用。"
        case .migrationRequired:
            return "请更新到最新版本的应用。"
        case .storeError:
            return "请检查设备存储空间是否充足，并尝试重新启动应用。"
        default:
            return nil
        }
    }
} 