import Foundation

/// 数据管理错误类型
enum DataManagerError: LocalizedError {
    case invalidEntity
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case invalidData
    case contextError
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
        case .unknown(let error):
            return "未知错误: \(error.localizedDescription)"
        }
    }
} 