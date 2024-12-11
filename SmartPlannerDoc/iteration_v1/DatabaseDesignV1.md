# SmartPlanner V1.0 数据库设计

## 一、设计说明
本设计文档针对SmartPlanner第一次迭代的数据库结构。主要实现：
- 计划区间的创建和管理
- 基础计划的创建和管理
- 类别系统
- 模板系统（区间模板和计划模板）

## 二、表结构设计

### 1. 类别表 (PlanCategory)

#### 属性
- `id` UUID PRIMARY KEY  // 类别的唯一标识符
- `name` VARCHAR(50) NOT NULL  // 类别名称
- `color` VARCHAR(20) NULL  // 类别颜色，可选
- `level` INTEGER DEFAULT 0  // 层级深度，0表示顶级
- `path` VARCHAR(255) NULL  // 完整类别路径，可选
- `isVisible` BOOLEAN DEFAULT true  // 是否显示
- `displayOrder` INTEGER NULL  // 显示顺序，可选
- `createdAt` TIMESTAMP NOT NULL  // 创建时间
- `updatedAt` TIMESTAMP NOT NULL  // 最后更新时间
- `deletedAt` TIMESTAMP NULL  // 软删除时间标记，可选

#### 关系
- `parent` 多对一关系指向 PlanCategory  // 父类别，可选
- `children` 一对多关系指向 PlanCategory  // 子类别，可选
- `planTemplates` 一对多关系指向 PlanTemplate  // 关联的计划模板，可选

### 2. 计划区间模板表 (PlanBlockTemplate)

#### 属性
- `id` UUID PRIMARY KEY  // 区间模板的唯一标识符
- `name` VARCHAR(100) NOT NULL  // 区间模板名称
- `color` VARCHAR(20) NULL  // 显示颜色，可选
- `desc` TEXT NULL  // 区间描述，可选
- `isVisible` BOOLEAN DEFAULT true  // 是否在日历中显示
- `createdAt` TIMESTAMP NOT NULL  // 创建时间
- `updatedAt` TIMESTAMP NOT NULL  // 最后更新时间
- `deletedAt` TIMESTAMP NULL  // 软删除时间标记，可选

#### 关系
- `blockInstances` 一对多关系指向 PlanBlockInstance  // 区间实例，可选

### 3. 计划区间实例表 (PlanBlockInstance)

#### 属性
- `id` UUID PRIMARY KEY  // 区间实例的唯一标识符
- `startAt` TIMESTAMP NOT NULL  // 开始时间
- `endAt` TIMESTAMP NOT NULL  // 结束时间
- `createdAt` TIMESTAMP NOT NULL  // 创建时间
- `updatedAt` TIMESTAMP NOT NULL  // 最后更新时间
- `deletedAt` TIMESTAMP NULL  // 软删除时间标记，可选

#### 关系
- `blockTemplate` 多对一关系指向 PlanBlockTemplate  // 关联的区间模板
- `planInstances` 一对多关系指向 PlanInstance  // 包含的计划实例，可选

### 4. 计划模板表 (PlanTemplate)

#### 属性
- `id` UUID PRIMARY KEY  // 计划模板的唯一标识符
- `name` VARCHAR(100) NOT NULL  // 计划模板名称
- `color` VARCHAR(20) NULL  // 显示颜色，可选
- `isFixedTime` BOOLEAN DEFAULT false  // 是否为固定时间计划
- `isReminderEnabled` BOOLEAN DEFAULT true  // 是否启用提醒
- `reminderTime` INTEGER NULL  // 提前提醒时间（分钟），可选
- `priority` INTEGER NULL  // 优先级（1-5），可选
- `difficulty` INTEGER NULL  // 难度等级（1-5），可选
- `tags` TEXT NULL  // 标签，可选
- `createdAt` TIMESTAMP NOT NULL  // 创建时间
- `updatedAt` TIMESTAMP NOT NULL  // 最后更新时间
- `deletedAt` TIMESTAMP NULL  // 软删除时间标记，可选

#### 关系
- `planCategory` 多对一关系指向 PlanCategory  // 关联的类别，可选
- `planInstances` 一对多关系指向 PlanInstance  // 计划实例，可选

### 5. 计划实例表 (PlanInstance)

#### 属性
- `id` UUID PRIMARY KEY  // 计划实例的唯一标识符
- `startTime` TIMESTAMP NOT NULL  // 开始时间
- `endTime` TIMESTAMP NOT NULL  // 结束时间
- `duration` INTEGER NOT NULL  // 持续时长（分钟）
- `isReminderEnabled` BOOLEAN DEFAULT true  // 是否启用提醒
- `reminderTime` INTEGER NULL  // 提醒时间，可选
- `priority` INTEGER NULL  // 优先级（1-5），可选
- `difficulty` INTEGER NULL  // 难度等级（1-5），可选
- `createdAt` TIMESTAMP NOT NULL  // 创建时间
- `updatedAt` TIMESTAMP NOT NULL  // 最后更新时间
- `deletedAt` TIMESTAMP NULL  // 软删除时间标记，可选

#### 关系
- `planTemplate` 多对一关系指向 PlanTemplate  // 关联的计划模板
- `blockInstance` 多对一关系指向 PlanBlockInstance  // 所属的区间实例

## 三、删除规则

### 1. 级联删除（Cascade）
- PlanCategory.children -> PlanCategory  // 删除父类别时级联删除子类别
- PlanCategory.planTemplates -> PlanTemplate  // 删除类别时级联删除关联的计划模板
- PlanTemplate.planInstances -> PlanInstance  // 删除计划模板时级联删除关联的计划实例
- PlanBlockInstance.planInstance -> PlanInstance  // 删除区间实例时级联删除包含的计划实例

### 2. 清空引用（Nullify）
- PlanCategory.parent -> PlanCategory  // 删除父类别时子类别的parent引用置空
- PlanTemplate.planCategory -> PlanCategory  // 删除类别时计划模板的planCategory引用置空
- PlanInstance.planTemplate -> PlanTemplate  // 删除计划模板时计划实例的planTemplate引用置空
- PlanInstance.blockInstances -> PlanBlockInstance  // 删除区间实例时计划实例的blockInstances引用置空
- PlanBlockInstance.blockTemplate -> PlanBlockTemplate  // 删除区间模板时区间实例的blockTemplate引用置空

## 四、数据约束

### 1. 时间约束
- PlanInstance: endTime > startTime
- PlanBlockInstance: endAt > startAt
- PlanInstance的时间范围必须在其所属PlanBlockInstance的时间范围内

### 2. 值约束
- priority: 1-5之间的整数（如果提供）
- difficulty: 1-5之间的整数（如果提供）
- level: 非负整数
- displayOrder: 非负整数（如果提供）

## 五、索引设计

### PlanCategory
- idx_category_parent (parent)  // 用于查找子类别
- idx_category_path (path)  // 用于按路径快速查找类别
- idx_category_level (level)  // 用于按层级查找类别

### PlanTemplate
- idx_plan_template_category (category)  // 用于类别查找计划模板
- idx_plan_template_name (name)  // 用于按名称快速查找计划模板

### PlanInstance
- idx_plan_instance_template (planTemplate)  // 用于查找特定模板的所有实例
- idx_plan_instance_block (blockInstance)  // 用于查找特定区间内的所有计划
- idx_plan_instance_date (startTime, endTime)  // 用于日期范围查询

### PlanBlockInstance
- idx_block_instance_template (blockTemplate)  // 用于查找特定模板的所有区间实例
- idx_block_instance_date (startAt, endAt)  // 用于日期范围查询

