# SmartPlanner Project Structure
项目结构更新原则：
1. 项目结构清晰，易于理解和维护
2. 根据项目真实结构，调整项目结构

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
│   │   ├── Services/                 # 服务层
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
- `SmartPlanner/SmartPlanner/SmartPlannerApp.swift`: App 生命周期管理和初始化配置
- `SmartPlanner/SmartPlanner/ContentView.swift`: 应用程序主视图
- `SmartPlanner/SmartPlanner/Models/`: 包含所有数据模型定义和业务逻辑
- `SmartPlanner/SmartPlanner/Views/`: 包含所有 SwiftUI 视图组件
- `SmartPlanner/SmartPlanner/ViewModels/`: 包含视图数据处理和业务逻辑
- `SmartPlanner/SmartPlanner/Services/`: 包含各种服务实现
- `SmartPlanner/SmartPlanner/Utilities/`: 包含通用工具和扩展方法
- `SmartPlanner/SmartPlanner/SmartPlanner.xcdatamodeld/`: Core Data 数据模型定义

### 测试文件
- `SmartPlanner/SmartPlannerTests/`: 包含单元测试和集成测试
- `SmartPlanner/SmartPlannerUITests/`: 包含UI自动化测试
