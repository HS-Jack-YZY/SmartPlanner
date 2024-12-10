//
//  CategoryService.swift
//  SmartPlanner
//
//  Created by HS_Jack_YZY on 2024/12/11.
//

import CoreData
import Foundation

/// Category 服务协议
protocol CategoryServiceProtocol {
    /// 创建新类别
    /// - Parameters:
    ///   - name: 类别名称
    ///   - color: 类别颜色（可选）
    ///   - parent: 父类别（可选）
    /// - Returns: 创建的类别实体
    func createCategory(name: String, color: String?, parent: Category?) throws -> Category
    
    /// 获取所有顶级类别
    /// - Returns: 顶级类别列表
    func fetchRootCategories() throws -> [Category]
    
    /// 获取指定类别的子类别
    /// - Parameter parent: 父类别
    /// - Returns: 子类别列表
    func fetchChildren(of parent: Category) throws -> [Category]
    
    /// 获取类别的完整路径
    /// - Parameter category: 目标类别
    /// - Returns: 从根类别到当前类别的路径
    func fetchPath(for category: Category) throws -> [Category]
    
    /// 更新类别信息
    /// - Parameters:
    ///   - category: 要更新的类别
    ///   - name: 新名称（可选）
    ///   - color: 新颜色（可选）
    func updateCategory(_ category: Category, name: String?, color: String?) throws
    
    /// 移动类别到新的父类别
    /// - Parameters:
    ///   - category: 要移动的类别
    ///   - newParent: 新的父类别（nil表示移动到顶级）
    func moveCategory(_ category: Category, to newParent: Category?) throws
    
    /// 删除类别（软删除）
    /// - Parameter category: 要删除的类别
    func deleteCategory(_ category: Category) throws
    
    /// 检查类别名称是否可用
    /// - Parameters:
    ///   - name: 要检查的名称
    ///   - parent: 父类别（可选）
    ///   - excluding: 排除的类别（用于更新时）
    /// - Returns: 名称是否可用
    func isNameAvailable(_ name: String, parent: Category?, excluding: Category?) throws -> Bool
}

/// Category 服务实现
final class CategoryService: CategoryServiceProtocol {
    /// CoreData 管理器
    private let coreDataManager: CoreDataManager
    
    /// 初始化方法
    /// - Parameter coreDataManager: CoreData 管理器实例
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - 创建操作
    
    func createCategory(name: String, color: String?, parent: Category?) throws -> Category {
        // 验证名称是否可用
        guard try isNameAvailable(name, parent: parent, excluding: nil) else {
            throw CategoryError.nameAlreadyExists
        }
        
        let context = coreDataManager.mainContext
        let category = coreDataManager.create(Category.self, context: context)
        
        // 设置基本属性
        category.id = UUID()
        category.name = name
        category.color = color
        category.createdAt = Date()
        category.updatedAt = Date()
        category.isVisible = true
        
        // 设置父类别关系
        if let parent = parent {
            category.parent = parent
            category.level = parent.level + 1
            // 生成路径
            if let parentPath = parent.path {
                category.path = "\(parentPath)/\(category.id?.uuidString ?? "")"
            } else {
                category.path = category.id?.uuidString
            }
        } else {
            category.level = 0
            category.path = category.id?.uuidString
        }
        
        try coreDataManager.saveContext(context)
        return category
    }
    
    // MARK: - 查询操作
    
    func fetchRootCategories() throws -> [Category] {
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: "parent == nil AND deletedAt == nil")
        return try coreDataManager.fetch(Category.self, predicate: predicate, context: context)
    }
    
    func fetchChildren(of parent: Category) throws -> [Category] {
        let context = coreDataManager.mainContext
        let predicate = NSPredicate(format: "parent == %@ AND deletedAt == nil", parent)
        return try coreDataManager.fetch(Category.self, predicate: predicate, context: context)
    }
    
    func fetchPath(for category: Category) throws -> [Category] {
        guard let path = category.path else { return [] }
        
        let components = path.components(separatedBy: "/")
        let context = coreDataManager.mainContext
        
        var result: [Category] = []
        for component in components {
            guard let uuid = UUID(uuidString: component),
                  let predicate = NSPredicate(format: "id == %@", uuid as CVarArg),
                  let category = try coreDataManager.fetch(Category.self,
                                                         predicate: predicate,
                                                         context: context).first
            else { continue }
            
            result.append(category)
        }
        
        return result
    }
    
    // MARK: - 更新操作
    
    func updateCategory(_ category: Category, name: String?, color: String?) throws {
        // 如果要更新名称，先验证是否可���
        if let name = name {
            guard try isNameAvailable(name, parent: category.parent, excluding: category) else {
                throw CategoryError.nameAlreadyExists
            }
            category.name = name
        }
        
        if let color = color {
            category.color = color
        }
        
        category.updatedAt = Date()
        
        try coreDataManager.saveContext(coreDataManager.mainContext)
    }
    
    func moveCategory(_ category: Category, to newParent: Category?) throws {
        // 验证不会造成循环引用
        if let newParent = newParent {
            var current = newParent
            while let parent = current.parent {
                if parent == category {
                    throw CategoryError.circularReference
                }
                current = parent
            }
        }
        
        // 验证新位置的名称是否可用
        guard try isNameAvailable(category.name ?? "", parent: newParent, excluding: category) else {
            throw CategoryError.nameAlreadyExists
        }
        
        let context = coreDataManager.mainContext
        
        // 更新层级和路径
        category.parent = newParent
        if let newParent = newParent {
            category.level = newParent.level + 1
            if let parentPath = newParent.path {
                category.path = "\(parentPath)/\(category.id?.uuidString ?? "")"
            }
        } else {
            category.level = 0
            category.path = category.id?.uuidString
        }
        
        // 递归更新所有子类别的层级和路径
        try updateChildrenLevelsAndPaths(of: category)
        
        try coreDataManager.saveContext(context)
    }
    
    // MARK: - 删除操作
    
    func deleteCategory(_ category: Category) throws {
        let context = coreDataManager.mainContext
        try coreDataManager.delete(category, context: context)
    }
    
    // MARK: - 验证方法
    
    func isNameAvailable(_ name: String, parent: Category?, excluding: Category?) throws -> Bool {
        let context = coreDataManager.mainContext
        var predicateFormat = "name == %@ AND deletedAt == nil"
        var predicateArgs: [Any] = [name]
        
        if let parent = parent {
            predicateFormat += " AND parent == %@"
            predicateArgs.append(parent)
        } else {
            predicateFormat += " AND parent == nil"
        }
        
        if let excluding = excluding {
            predicateFormat += " AND self != %@"
            predicateArgs.append(excluding)
        }
        
        let predicate = NSPredicate(format: predicateFormat, argumentArray: predicateArgs)
        let existing = try coreDataManager.fetch(Category.self, predicate: predicate, context: context)
        return existing.isEmpty
    }
    
    // MARK: - 私有辅助方法
    
    /// 递归更新子类别的层级和路径
    private func updateChildrenLevelsAndPaths(of category: Category) throws {
        guard let children = category.children as? Set<Category> else { return }
        
        for child in children {
            child.level = category.level + 1
            if let parentPath = category.path {
                child.path = "\(parentPath)/\(child.id?.uuidString ?? "")"
            }
            try updateChildrenLevelsAndPaths(of: child)
        }
    }
}

// MARK: - 错误定义

enum CategoryError: LocalizedError {
    case nameAlreadyExists
    case circularReference
    
    var errorDescription: String? {
        switch self {
        case .nameAlreadyExists:
            return "类别名称已存在"
        case .circularReference:
            return "不能将类别移动到其子类别下"
        }
    }
} 