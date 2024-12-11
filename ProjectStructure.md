# SmartPlanner Project Structure

```
SmartPlanner/
├── SmartPlannerDoc/                    # 项目文档目录
│   ├── iteration_v1/                   # 第一轮迭代相关文档
│   │   ├── SmartplannerV1.md          # 迭代实现计划和需求
│   │   ├── tddV1.md                   # 技术设计文档
│   │   └── prdV1.md                   # 产品需求文档
│   ├── Development_Progress.md         # 开发进度追踪
│   ├── Smartplanner.md                # 项目整体说明
│   └── CodingPrinciples.md            # 代码编写原则
│
├── SmartPlanner/                       # 主项目目录
│   ├── SmartPlanner/                  # 源代码目录
│   │   ├── SmartPlannerApp.swift      # 应用程序入口
│   │   ├── Models/                    # 数据模型
│   │   │   ├── PlanningZone.swift     # 计划区间模型
│   │   │   ├── Plan.swift            # 计划模型
│   │   │   └── Enums/                # 枚举定义
│   │   │
│   │   ├── Views/                    # 视图层
│   │   │   ├── Calendar/            # 日历相关视图
│   │   │   ├── Plan/               # 计划相关视图
│   │   │   └── Components/         # 通用组件
│   │   │
│   │   ├── ViewModels/             # 视图模型层
│   │   │   ├── CalendarViewModel/  # 日历视图模型
│   │   │   └── PlanViewModel/      # 计划视图模型
│   │   │
│   │   ├── Services/               # 服务层
│   │   │   ├── DataManager/        # 数据管理服务
│   │   │   │   ├── CoreDataStack.swift    # Core Data 基础设施
│   │   │   │   ├── DataManager.swift      # 数据管理器
│   │   │   │   └── DataManagerError.swift # 错误类型定义
│   │   │   └── NotificationManager/# 通知管理服务
│   │   │
│   │   └── Utilities/              # 工具层
│   │       ├── Extensions/         # 扩展方法
│   │       └── Constants/          # 常量定义
│   │
│   ├── SmartPlannerTests/          # 单元测试目录
│   └── SmartPlannerUITests/        # UI测试目录
│
├── README.md                       # 项目说明文档
├── LICENSE                        # GNU General Public License v3.0
└── .gitignore                    # Git忽略文件配置

```

## 文件说明

### 文档文件
- `SmartPlannerDoc/iteration_v1/SmartplannerV1.md`: 包含用户场景、开发步骤、技术要点和项目结构设计
- `SmartPlannerDoc/iteration_v1/tddV1.md`: 包含系统架构、数据模型、核心类、安全、性能和测试策略
- `SmartPlannerDoc/iteration_v1/prdV1.md`: 包含产品定位、功能需求、UI/UX设计规范和发布计划
- `SmartPlannerDoc/Smartplanner.md`: 描述项目设计初衷、核心功能和技术架构
- `SmartPlannerDoc/CodingPrinciples.md`: 定义代码编写规范和原则

### 源代码文件
- `SmartPlanner/SmartPlanner/SmartPlannerApp.swift`: App 生命周期管理和初始化配置
- `SmartPlanner/SmartPlanner/Models/`: 包含所有数据模型定义和业务逻辑
- `SmartPlanner/SmartPlanner/Views/`: 包含所有 SwiftUI 视图组件
- `SmartPlanner/SmartPlanner/ViewModels/`: 包含视图数据处理和业务逻辑
- `SmartPlanner/SmartPlanner/Services/DataManager/`: 数据管理服务实现
- `SmartPlanner/SmartPlanner/Services/NotificationManager/`: 通知管理服务
- `SmartPlanner/SmartPlanner/Utilities/`: 包含通用工具和扩展方法

### 测试文件
- `SmartPlanner/SmartPlannerTests/`: 包含单元测试和集成测试
- `SmartPlanner/SmartPlannerUITests/`: 包含UI自动化测试
