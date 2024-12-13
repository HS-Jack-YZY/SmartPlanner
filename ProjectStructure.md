# SmartPlanner 项目结构

> 📝 **文档更新指南**
> 
> 本文档旨在准确反映项目的目录结构。更新本文档时，请遵循以下原则：
> 
> ### 基本原则
> 
> 1. **实际性原则**
>    - 只记录实际存在的目录和文件
>    - 不记录计划中但未创建的内容
>    - 使用 `find` 等命令验证文件存在
> 
> 2. **完整性原则**
>    - 从项目根目录开始记录
>    - 包含所有关键配置文件
>    - 完整展示目录层级关系
> 
> 3. **层次性原则**
>    - 使用缩进表示目录层级
>    - 保持结构的一致性
>    - 用空行分隔主要部分
> 
> ### 更新步骤
> 
> 1. **收集信息**
>    ```bash
>    # 列出所有目录
>    find . -type d
>    
>    # 列出所有文件
>    find . -type f
>    ```
> 
> 2. **验证结构**
>    - 确认所有路径正确
>    - 验证文件实际存在
>    - 检查注释准确性
> 
> 3. **保持格式**
>    - 使用统一的注释风格（如 `# 说明文字`）
>    - 遵循既定的树形结构格式
>    - 保持文档各部分的顺序
>
> ---

## 目录结构

```
SmartPlannerProject/                # 项目根目录
├── .git/                          # Git版本控制目录
├── .gitignore                     # Git忽略配置文件
├── LICENSE                        # 开源许可证
├── README.md                      # 项目说明文档
├── ProjectStructure.md            # 项目结构文档
│
├── SmartPlannerDoc/               # 项目文档
│   ├── Development_Progress.md    # 开发进度记录
│   ├── iteration_v1/             # 第一轮迭代文档
│   │   ├── DevelopmentGuideV1.md # 开发指南
│   │   ├── prdV1.md             # 产品需求文档
│   │   └── tddV1.md             # 技术设计文档
│   └── Smartplanner.md          # 项目概述
│
├── SmartPlanner/                 # Xcode项目目录
│   ├── SmartPlanner/            # 主项目目录
│   │   ├── Models/              # 模型层
│   │   │   ├── CoreDataModels/  # Core Data 实体
│   │   │   ├── PlanCategory+CoreDataClass.swift
│   │   │   ├── PlanCategory+CoreDataProperties.swift
│   │   │   ├── PlanTemplate+CoreDataClass.swift
│   │   │   ├── PlanTemplate+CoreDataProperties.swift
│   │   │   ├── PlanInstance+CoreDataClass.swift
│   │   │   ├── PlanInstance+CoreDataProperties.swift
│   │   │   ├── PlanBlockTemplate+CoreDataClass.swift
│   │   │   ├── PlanBlockTemplate+CoreDataProperties.swift
│   │   │   ├── PlanBlockInstance+CoreDataClass.swift
│   │   │   └── PlanBlockInstance+CoreDataProperties.swift
│   │   ├── Enums/                    # 枚举定义
│   │   ├── Extensions/               # 模型扩展
│   │   ├── Helpers/                  # 辅助工具类
│   │   └── Protocols/                # 协议定义
│   │
│   ├── Services/                     # 服务层
│   │   └── DataManager/              # 数据管理服务
│   │       ├── CoreDataStack.swift   # Core Data基础设施
│   │       ├── DataManager.swift     # 数据管理器
│   │       └── DataManagerError.swift # 错误类型定义
│   │
│   ├── Theme/                        # 主题系统
│   │   ├── ColorTheme.swift         # 颜色主题定义
│   │   ├── FontTheme.swift          # 字体主题定义
│   │   ├── ThemeManager.swift       # 主题管理器
│   │   └── ThemePreview.swift       # 主题预览视图
│   │
│   ├── Utilities/                    # 工具层
│   ├── ViewModels/                   # 视图模型层
│   ├── Views/                        # 视图层
│   │
│   ├── Assets.xcassets/              # 资源文件
│   │   ├── AppIcon.appiconset/      # 应用图标
│   │   ├── AccentColor.colorset/    # 强调色
│   │   └── Colors/                   # 颜色源
│   │       ├── PrimaryColor.colorset
│   │       ├── SecondaryColor.colorset
│   │       ├── BackgroundColor.colorset
│   │       ├── SecondaryBackgroundColor.colorset
│   │       ├── PrimaryTextColor.colorset
│   │       ├── SecondaryTextColor.colorset
│   │       ├── WorkBlockColor.colorset
│   │       ├── PersonalBlockColor.colorset
│   │       ├── SuccessColor.colorset
│   │       ├── WarningColor.colorset
│   │       └── ErrorColor.colorset
│   │
│   ├── Preview Content/              # 预览内容
│   │   └── Preview Assets.xcassets   # 预览资源
│   │
│   ├── SmartPlanner.xcdatamodeld/   # Core Data模型文件
│   │   └── SmartPlanner.xcdatamodel # 数据模型定义
│   │
│   ├── ContentView.swift            # 主内容视图（集成主题预览）
│   └── SmartPlannerApp.swift        # 应用程序入口
│
├── SmartPlannerTests/               # 单元测试目录
│   ├── Models/                      # 模型测试
│   │   └── CoreDataTests/          # Core Data测试
│   │       └── EntityTests/        # 实体测试
│   │           └── PlanCategoryTests.swift
│   ├── Services/                    # 服务测试
│   │   └── CoreData/               # Core Data服务测试
│   ├── Theme/                      # 主题系统测试
│   │   └── ThemeTests.swift        # 主题功能测试
│   ├── Views/                      # 视图测试
│   ├── ViewModels/                 # 视图模型测试
│   ├── Helpers/                    # 辅助工具测试
│   ├── TestHelpers/                # 测试辅助工具
│   │   ├── TestLogger.swift        # 测试日志工具
│   │   └── TestCoreDataStack.swift # 测试数据
│   └── SmartPlannerTests.swift     # 测试入口文件
│
└── SmartPlannerUITests/            # UI测试目录
    ├── SmartPlannerUITests.swift           # UI测试用例
    └── SmartPlannerUITestsLaunchTests.swift # 启动测试

```

## 文件命名规范

1. **Swift 文件**
   - 使用 PascalCase
   - 遵循功能+类型的命名方式
   - 例如：`ThemeManager.swift`, `ColorTheme.swift`

2. **资源文件**
   - 使用 PascalCase
   - 遵循功能+类型的命名方式
   - 例如：`PrimaryColor.colorset`, `AppIcon.appiconset`

3. **测试文件**
   - 使用被测试类名+Tests的命名方式
   - 例如：`ThemeTests.swift`, `PlanCategoryTests.swift`

## 模块说明

1. **Models**
   - Core Data 实体定义（计划、类别、区间等）
   - 数据模型及其属性
   - 模型扩展和协议

2. **Services**
   - 数据持久化服务
   - Core Data 基础设施
   - 错误处理机制

3. **Theme**
   - 颜色主题管理
   - 字体主题管理
   - 主题预览功能
   - 深色模式支持

4. **Utilities**
   - 工具类
   - 辅助功能

5. **Views & ViewModels**
   - 视图层实现
   - 视图数据处理
   - 业务逻辑封装

6. **Tests**
   - 单元测试（Models, Services, Theme等）
   - UI测试
   - 测试辅助工具
```
