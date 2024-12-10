# SmartPlanner V1.0 开发步骤指南

## 1. 项目初始化（0.5天）

### 1.1 创建项目
1. 使用Xcode 16创建新项目
   - 选择App模板
   - 项目名称：SmartPlanner
   - 开发语言：Swift
   - 界面框架：SwiftUI
   - 最低支持版本：iOS 15.0

### 1.2 配置项目
1. 设置开发团队
2. 配置Bundle Identifier
3. 设置版本号和构建号
4. 配置开发证书和描述文件

### 1.3 Git配置
1. 初始化Git仓库
2. 创建.gitignore文件
3. 设置首次提交

## 2. 数据层实现（2天）

### 2.1 CoreData模型创建（0.5天）
1. 创建CoreData Model文件
2. 实现数据模型
   ```swift
   // PlanningZone.swift
   class PlanningZone: NSManagedObject {
       @NSManaged var id: UUID
       @NSManaged var name: String
       @NSManaged var color: String
       @NSManaged var startTime: Date
       @NSManaged var endTime: Date
       @NSManaged var isTemplate: Bool
       @NSManaged var plans: Set<Plan>
       @NSManaged var createdAt: Date
       @NSManaged var updatedAt: Date
   }

   // Plan.swift
   class Plan: NSManagedObject {
       @NSManaged var id: UUID
       @NSManaged var name: String
       @NSManaged var startTime: Date
       @NSManaged var endTime: Date
       @NSManaged var isTemplate: Bool
       @NSManaged var category: Category?
       @NSManaged var planningZone: PlanningZone?
       @NSManaged var reminder: Reminder?
       @NSManaged var isFixedTime: Bool
       @NSManaged var status: String
       @NSManaged var createdAt: Date
       @NSManaged var updatedAt: Date
   }
   ```

### 2.2 CoreData管理器实现（1天）
1. 创建CoreDataStack
   ```swift
   class CoreDataStack {
       static let shared = CoreDataStack()
       let persistentContainer: NSPersistentContainer
       
       var viewContext: NSManagedObjectContext {
           persistentContainer.viewContext
       }
       
       func saveContext() throws
       func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) throws -> Void) async throws
   }
   ```

2. 实现CRUD操作
   ```swift
   extension CoreDataStack {
       func create<T: NSManagedObject>(_ type: T.Type) -> T
       func fetch<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate?) -> [T]
       func delete(_ object: NSManagedObject) throws
   }
   ```

### 2.3 数据管理器实现（0.5天）
1. 实现PlanManager
2. 实现ZoneManager
3. 实现CategoryManager

## 3. UI层实现（4天）

### 3.1 基���UI组件（1天）
1. 实现颜色扩展
   ```swift
   extension Color {
       static let systemBackground = Color(UIColor.systemBackground)
       static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
       // ... 其他系统颜色
   }
   ```

2. 实现通用组件
   ```swift
   struct CustomButton: View {
       let title: String
       let action: () -> Void
       
       var body: some View {
           Button(action: action) {
               Text(title)
                   .frame(maxWidth: .infinity)
                   .padding()
                   .background(Color.accentColor)
                   .foregroundColor(.white)
                   .cornerRadius(10)
           }
       }
   }
   ```

### 3.2 日历视图实现（2天）
1. 实现CalendarView
   ```swift
   struct CalendarView: View {
       @StateObject private var viewModel: CalendarViewModel
       
       var body: some View {
           VStack {
               // 日历头部
               CalendarHeaderView()
               
               // 日历网格
               CalendarGridView()
               
               // 时间指示器
               if viewModel.showTimeIndicator {
                   TimeIndicatorView()
               }
           }
       }
   }
   ```

2. 实现拖拽系统
   ```swift
   struct DraggablePlanView: View {
       @State private var isDragging = false
       @GestureState private var dragOffset = CGSize.zero
       
       var body: some View {
           // 实现拖拽视图
       }
   }
   ```

### 3.3 计划管理视图（1天）
1. 实现计划列表视图
2. 实现计划详情视图
3. 实现计划编辑视图

## 4. 业务逻辑实现（2天）

### 4.1 计划管理逻辑（1天）
1. 实现计划创建流程
2. 实现计划编辑流程
3. 实现计划删除流程
4. 实现计划状态管理

### 4.2 区间管理逻辑（1天）
1. 实现区间创建流程
2. 实现区间编辑流程
3. 实现计划分配逻辑
4. 实现时间冲突处理

## 5. 本地通知实现（1天）

### 5.1 通知权限管理
```swift
class NotificationManager {
    static let shared = NotificationManager()
    
    func requestAuthorization() async throws -> Bool
    func scheduleNotification(for plan: Plan) async throws
    func cancelNotification(for plan: Plan) async throws
}
```

### 5.2 通知处理
1. 实现通知触发逻辑
2. 实现通知响应处理
3. 实现通知更新机制

## 6. 测试与优化（2天）

### 6.1 单元测试
1. 数据模型测试
2. 业务逻辑测试
3. 工具类测试

### 6.2 UI测试
1. 视图交互测试
2. 导航流程测试
3. 手势操作测试

### 6.3 性能优化
1. 内存优化
2. 渲染性能优化
3. 数据加载优化

## 7. 打包发布（0.5天）

### 7.1 发布准备
1. 版本号更新
2. 编译配置检查
3. 证书配置检查

### 7.2 打包流程
1. 创建Archive
2. 导出IPA
3. 准备发布材料

## 开发注意事项

### 1. 代码规范
- 使用SwiftLint保持代码风格一致
- 遵循MVVM架构模式
- 使用Swift新特性（async/await）

### 2. 性能考虑
- 使用懒加载机制
- 实现视图复用
- 优化数据查询

### 3. 测试要求
- 核心功能单元测试覆盖率>80%
- UI测试覆盖主要用户流程
- 性能测试达到目标指标

### 4. Git工作流
- 使用feature分支开发新功能
- 提交信息遵循规范
- 代码审查后合并

## 预计时间安排
- 项目初始化：0.5天
- 数据层实现：2天
- UI层实现：4天
- 业务逻辑实现：2天
- 本地通知实现：1天
- 测试与优化：2天
- 打包发布：0.5天

总计：12个工作日

## 关键节点检查项

### 1. 项目初始化完成检查
- [ ] 项目能够正常编译运行
- [ ] Git仓库配置完成
- [ ] 开发环境配置完成

### 2. 数据层完成检查
- [ ] CoreData模型创建完成
- [ ] CRUD操作实现完成
- [ ] 数据管理器测试通过

### 3. UI层完成检查
- [ ] 基础组件库完成
- [ ] 日历视图功能完整
- [ ] 拖拽交互正常

### 4. 功能完成检查
- [ ] 计划管理功能完整
- [ ] 区间管理功能完整
- [ ] 本地通知功能正常

### 5. 发布准备检查
- [ ] 所有测试通过
- [ ] 性能指标达标
- [ ] 发布材料准备完成 