# SmartPlanner 项目结构说明

## 文档目录 (SmartPlannerDoc/)
### 迭代文档 (iteration_v1/)
- `prdV1.md` - 产品需求文档
  - 产品定位
  - 功能需求
  - 非功能需求
  - UI/UX设计规范
  - 兼容性要求
  - 发布计划
  
- `tddV1.md` - 技术设计文档
  - 系统架构设计
  - 数据模型设计
  - 核心类设计
  - 安全设计
  - 性能优化
  - 测试策略

- `DevelopmentGuideV1.md` - 开发步骤指南
  - 详细开发流程
  - 具体实现步骤
  - 时间规划
  - 注意事项

### 核心文档
- `Smartplanner.md` - 项目整体说明
  - 设计初衷
  - 核心功能模块
  - 技术架构
  - 前后端职责划分

- `DevelopmentProgress.md` - 开发进度追踪
  - 已完成功能
  - 进行中的任务
  - 待办事项
  - 问题记录

## 源代码目录 (SmartPlanner/)
### 当前项目结构
- `SmartPlanner.xcodeproj/` - Xcode 项目配置文件

- `SmartPlanner/` - 主项目目录
  - `SmartPlannerApp.swift` - 应用程序入口文件
  - `ContentView.swift` - 主视图文件
  - `Assets.xcassets/` - 资源文件目录
  - `Preview Content/` - SwiftUI 预览内容
  - `SmartPlanner.xcdatamodeld/` - Core Data 数据模型
  - `Models/` - 数据模型层
    - `CoreData/` - CoreData 实体类
      - `Category+CoreDataClass.swift` - 类别实体类
      - `Category+CoreDataProperties.swift` - 类别实体属性
      - `PlanTemplate+CoreDataClass.swift` - 计划模板实体类
      - `PlanTemplate+CoreDataProperties.swift` - 计划模板实体属性
      - `PlanInstance+CoreDataClass.swift` - 计划实例实体类
      - `PlanInstance+CoreDataProperties.swift` - 计划实例实体属性
      - `PlanBlockTemplate+CoreDataClass.swift` - 计划区间模板实体类
      - `PlanBlockTemplate+CoreDataProperties.swift` - 计划区间模板实体属性
      - `PlanBlockInstance+CoreDataClass.swift` - 计划区间实例实体类
      - `PlanBlockInstance+CoreDataProperties.swift` - 计划区间实例实体属性
    - 负责数据实体定义
    - 数据转换和持久化
    - 业务模型
  - `Views/` - 视图层
    - 用户界面组件
    - 页面布局
    - 交互控件
  - `ViewModels/` - 视图模型层
    - 视图状态管理
    - 业务逻辑处理
    - 数据绑定
  - `Services/` - 服务层
    - `CoreData/` - CoreData 服务
      - `CoreDataManager.swift` - CoreData 核心管理类
        - 实现单例模式
        - 管理 CoreData 栈
        - 提供 CRUD 操作
        - 支持批量操作
      - `CategoryService.swift` - 类别服务类
        - 实现 CategoryServiceProtocol
        - 提供类别管理功能
        - 支持层级结构
        - 维护路径完整性
      - `PlanBlockTemplateService.swift` - 计划区间模板服务类
        - 实现 PlanBlockTemplateServiceProtocol
        - 提供模板管理功能
        - 支持实例创建
        - 实现数据验证
      - `PlanTemplateService.swift` - 计划模板服务类
        - 实现 PlanTemplateServiceProtocol
        - 提供模板管理功能
        - 支持类别关联
        - 实现优先级和难度管理
        - 支持实例创建和验证
      - `PlanBlockInstanceService.swift` - 计划区间实例服务类
        - 实现 PlanBlockInstanceServiceProtocol
        - 提供区间实例管理功能
        - 支持时间范围管理
        - 实现冲突检测
        - 维护计划实例关系
      - `PlanInstanceService.swift` - 计划实例服务类
        - 实现 PlanInstanceServiceProtocol
        - 提供计划实例管理功能
        - 支持时间范围管理
        - 实现优先级和难度管理
        - 支持提醒功能
        - 实现冲突检测
  - `Utilities/` - 工具层
    - 通用工具类
    - 扩展方法
    - 常量定义

- `SmartPlannerTests/` - 单元测试目录
  - `SmartPlannerTests.swift` - 测试基础配置文件
  - `CoreData/` - CoreData 相关测试
    - `CoreDataManagerTests.swift` - CoreData 管理器测试
      - 测试数据库初始化
      - 测试 CRUD 操作
      - 测试上下文管理
      - 测试并发操作
    - `CategoryServiceTests.swift` - 类别服务测试
      - 测试类别创建
      - 测试层级管理
      - 测试路径维护
      - 测试更新操作
      - 测试移动功能
      - 测试删除操作
      - 测试错误处理
    - `PlanBlockTemplateServiceTests.swift` - 计划区间模板服务测试
      - 测试模板创建
        - 基本创建功能
        - 重复名称处理
        - 无效持续时间验证
        - 无效时间范围验证
      - 测试模板查询
        - 按类别查询
      - 测试模板更新
        - 基本更新功能
        - 重复名称处理
      - 测试模板删除
        - 软删除验证
      - 测试错误处理
        - 名称重复错误
        - 持续时间错误
        - 时间范围错误
  - `Models/` - 模型测试
  - `ViewModels/` - 视图模型测试
  - `Services/` - 服务层测试
  - `Utilities/` - 工具测试
  - `Mocks/` - 模拟对象
  - `TestHelpers/` - 测试辅助工具

- `SmartPlannerUITests/` - UI测试目录
  - `SmartPlannerUITests.swift` - UI测试用例
  - `SmartPlannerUITestsLaunchTests.swift` - 启动测试用例

### 建议的项目结构
建议在 `SmartPlanner/` 主项目目录下采用以下结构：
- `Models/` - 数据模型层
  - 负责数据实体定义
  - 数据转换和持久化
  - 业务模型

- `Views/` - 视图层
  - 用户界面组件
  - 页面布局
  - 交互控件

- `ViewModels/` - 视图模型层
  - 视图状态管理
  - 业务逻辑处理
  - 数据绑定

- `Services/` - 服务层
  - 网络请求
  - 数据存储
  - 业务服务

- `Utilities/` - 工具层
  - 通用工具类
  - 扩展方法
  - 常量定义

建议在 `SmartPlannerTests/` 目录下包含：
- `CoreData/` - CoreData 相关测试
  - 实体服务测试
  - 数据管理测试
  - 关系维护测试
- `Models/` - 模型测试
  - 数据模型测试
  - 业务模型测试
- `ViewModels/` - 视图模型测试
  - 状态管理测试
  - 业务逻辑测试
- `Services/` - 服务层测试
  - API 测试
  - 业务服务测试
- `Utilities/` - 工具测试
  - 工具类测试
  - 扩展方法测试
- `Mocks/` - 模拟对象
  - 测试数据生成器
  - 模拟服务实现
- `TestHelpers/` - 测试辅助工具
  - 测试工具函数
  - 测试数据构建器

建议在 `SmartPlannerUITests/` 目录下包含：
- 界面交互测试
- 用户流程测试
- 性能测试

### Xcode 项目配置
- `SmartPlanner.xcodeproj/` - Xcode 项目配置文件
  - 构建设置
  - 依赖管理
  - 签名配置
  - 环境配置

## 文件依赖关系
```mermaid
graph TD
    PRD[prdV1.md] --> TDD[tddV1.md]
    PRD --> DG[DevelopmentGuideV1.md]
    TDD --> DG
    Smartplanner[Smartplanner.md] --> PRD
    DP[DevelopmentProgress.md] --> DG
```

## 版本控制
- `.gitignore` - Git忽略文件配置
- `LICENSE` - GNU General Public License v3.0
- `README.md` - 项目说明文档
- `ProjectStructure.md` - 项目结构说明文档
