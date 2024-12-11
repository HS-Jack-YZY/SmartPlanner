# SmartPlanner Project Structure

```
SmartPlannerProject/
├── SmartPlannerDoc/                    # 项目文档目录
│   ├── iteration_v1/                   # 第一轮迭代相关文档
│   │   ├── DevelopmentGuideV1.md      # 开发指南
│   │   ├── DatabaseDesignV1.md        # 数据库设计文档
│   │   ├── tddV1.md                   # 技术设计文档
│   │   └── prdV1.md                   # 产品需求文档
│   ├── Development_Progress.md         # 开发进度追踪
│   ├── Smartplanner.md                # 项目整体说明
│   └── CodingPrinciples.md            # 代码编写原则
│
├── SmartPlanner/                       # 主项目目录
│   ├── SmartPlanner.xcodeproj/        # Xcode项目配置文件
│   ├── SmartPlanner/                  # 源代码目录
│   │   ├── Models/                    # 数据模型
│   │   │   ├── CoreDataModels/       # Core Data实体模型
│   │   │   │   ├── PlanCategory+CoreDataClass.swift     # 类别实体类
│   │   │   │   ├── PlanCategory+CoreDataProperties.swift # 类别属性定义
│   │   │   │   ├── PlanBlockTemplate+CoreDataClass.swift     # 区间模板实体类
│   │   │   │   ├── PlanBlockTemplate+CoreDataProperties.swift # 区间模板属性定义
│   │   │   │   ├── PlanBlockInstance+CoreDataClass.swift     # 区间实例实体类
│   │   │   │   ├── PlanBlockInstance+CoreDataProperties.swift # 区间实例属性定义
│   │   │   │   ├── PlanTemplate+CoreDataClass.swift     # 计划模板实体类
│   │   │   │   ├── PlanTemplate+CoreDataProperties.swift # 计划模板属性定义
│   │   │   │   ├── PlanInstance+CoreDataClass.swift     # 计划实例实体类
│   │   │   │   └── PlanInstance+CoreDataProperties.swift # 计划实例属性定义
│   │   │   ├── Enums/               # 枚举定义
│   │   │   ├── Extensions/          # 模型扩展
│   │   │   ├── Helpers/            # 辅助工具类
│   │   │   └── Protocols/          # 协议定义
│   │   ├── Services/                 # 服务层
│   │   │   └── DataManager/         # 数据管理服务
│   │   │       ├── CoreDataStack.swift    # Core Data基础设施
│   │   │       ├── DataManager.swift      # 数据管理器
│   │   │       └── DataManagerError.swift # 错误类型定义
│   │   ├── SmartPlanner.xcdatamodeld/# Core Data模型
│   │   ├── Utilities/                # 工具层
│   │   ├── ViewModels/               # 视图模型层
│   │   ├── Views/                     # 视图层
│   │   ├── Preview Content/          # 预览内容
│   │   ├── Assets.xcassets/          # 资源文件
│   │   ├── ContentView.swift          # 主内容视图
│   │   └── SmartPlannerApp.swift      # 应用程序入口
│   │
│   ├── SmartPlannerTests/            # 单元测试目录
│   └── SmartPlannerUITests/          # UI测试目录
│
├── README.md                         # 项目说明文档
├── LICENSE                          # GNU General Public License v3.0
└── .gitignore                      # Git忽略文件配置
```

## 文件说明

### 文档文件
- `SmartPlannerDoc/iteration_v1/DevelopmentGuideV1.md`: 开发指南，包含开发流程和规范
- `SmartPlannerDoc/iteration_v1/DatabaseDesignV1.md`: 数据库设计文档，包含数据模型和关系
- `SmartPlannerDoc/iteration_v1/tddV1.md`: 包含系统架构、数据模型、核心类、安全、性能和测试策略
- `SmartPlannerDoc/iteration_v1/prdV1.md`: 包含产品定位、功能需求、UI/UX设计规范和发布计划
- `SmartPlannerDoc/Development_Progress.md`: 记录项目开发进度和里程碑
- `SmartPlannerDoc/Smartplanner.md`: 描述项目设计初衷、核心功能和技术架构
- `SmartPlannerDoc/CodingPrinciples.md`: 定义代码编写规范和原则

### 源代码文件
- `SmartPlanner/SmartPlanner/Models/`: 数据模型层
  - `CoreDataModels/`: Core Data实体模型定义
    - `PlanCategory+CoreDataClass.swift` 和 `Properties.swift`: 类别实体及其属性
    - `PlanBlockTemplate+CoreDataClass.swift` 和 `Properties.swift`: 区间模板实体及其属性
    - `PlanBlockInstance+CoreDataClass.swift` 和 `Properties.swift`: 区间实例实体及其属性
    - `PlanTemplate+CoreDataClass.swift` 和 `Properties.swift`: 计划模板实体及其属性
    - `PlanInstance+CoreDataClass.swift` 和 `Properties.swift`: 计划实例实体及其属性
  - `Enums/`: 枚举类型定义
  - `Extensions/`: 模型扩展方法
  - `Helpers/`: 模型相关辅助工具
  - `Protocols/`: 模型协议定义
- `SmartPlanner/SmartPlanner/Services/`: 服务层
  - `DataManager/`: 数据管理服务
    - `CoreDataStack.swift`: Core Data基础设施实现
    - `DataManager.swift`: 数据管理器实现
    - `DataManagerError.swift`: 错误类型定义
- `SmartPlanner/SmartPlanner/Utilities/`: 包含通用工具和扩展方法
- `SmartPlanner/SmartPlanner/SmartPlanner.xcdatamodeld/`: Core Data 数据模型定义
- `SmartPlanner/SmartPlanner/ContentView.swift`: 应用程序主视图
- `SmartPlanner/SmartPlanner/SmartPlannerApp.swift`: 应用程序入口和生命周期管理

### 测试文件
- `SmartPlanner/SmartPlannerTests/`: 包含单元测试和集成测试
- `SmartPlanner/SmartPlannerUITests/`: 包含UI自动化测试
```
