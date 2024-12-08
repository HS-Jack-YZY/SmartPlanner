# SmartPlanner V1.0 数据库设计

## 一、设计说明
本设计文档针对SmartPlanner第一次迭代的数据库结构。主要实现：
- 计划区间的创建和管理
- 基础计划的创建和管理
- 类别系统
- 模板系统（区间模板和计划模板）

## 二、表结构设计

### 1. 计划区间模板表 (PlanBlockTemplate)

### 属性
- `id` UUID PRIMARY KEY  // 区间模板的唯一标识符
- `name` VARCHAR(100) NOT NULL  // 区间模板名称，如"工作时间"、"学习时间"
- `color` VARCHAR(20)  // 在日历视图中显示的颜色
- `description` TEXT  // 区间模板的详细描述，选填
- `isVisible` BOOLEAN DEFAULT true  // 是否在日历视图中显示该类型区间
- `createdAt` TIMESTAMP NOT NULL  // 创建时间
- `updatedAt` TIMESTAMP NOT NULL  // 最后更新时间
- `deletedAt` TIMESTAMP  // 软删除时间标记

## 2. 计划区间实例表 (PlanBlockInstance)

### 属性
- `id` UUID PRIMARY KEY  // 区间实例的唯一标识符
- `templateId` UUID REFERENCES PlanBlockTemplate(id)  // 关联的区间模板ID
- `startAt` TIMESTAMP NOT NULL  // 区间开始时间
- `endAt` TIMESTAMP NOT NULL  // 区间结束时间
- `createdAt` TIMESTAMP NOT NULL  // 创建时间
- `updatedAt` TIMESTAMP NOT NULL  // 最后更新时间
- `deletedAt` TIMESTAMP  // 软删除时间标记

## 3. 计划模板表 (PlanTemplate)

### 属性
- `id` UUID PRIMARY KEY  // 计划模板的唯一标识符
- `name` VARCHAR(100) NOT NULL  // 计划模板名称，如"背单词"、"写代码"
- `color` VARCHAR(20)  // 在日历视图中显示的颜色
- `isFixedTime` BOOLEAN DEFAULT false  // 是否为固定时间计划
- `isReminderEnabled` BOOLEAN DEFAULT true  // 是否启用提醒
- `reminderTime` INTEGER  // 提前提醒时间（分钟）
- `priority` INTEGER  // 优先级（1-5，5最高）
- `difficulty` INTEGER  // 难度等级（1-5，5最难）
- `tags` TEXT  // 标签JSON字符串
- `createdAt` TIMESTAMP NOT NULL  // 创建时间
- `updatedAt` TIMESTAMP NOT NULL  // 最后更新时间
- `deletedAt` TIMESTAMP  // 软删除时间标记

### 关系
- `category` 多对一关系指向 Category  // 关联的类别

## 4. 计划实例表 (PlanInstance)

### 属性
- `id` UUID PRIMARY KEY  // 计划实例的唯一标识符
- `startTime` TIMESTAMP NOT NULL  // 计划开始时间
- `endTime` TIMESTAMP NOT NULL  // 计划结束时间
- `duration` INTEGER NOT NULL  // 计划持续时长（分钟）
- `isReminderEnabled` BOOLEAN DEFAULT true  // 是否启用提醒
- `reminderTime` INTEGER  // 提醒时间（可覆盖模板设置）
- `priority` INTEGER  // 优先级（可覆盖模板设置）
- `difficulty` INTEGER  // 难度等级（可覆盖模板设置）
- `createdAt` TIMESTAMP NOT NULL  // 创建时间
- `updatedAt` TIMESTAMP NOT NULL  // 最后更新时间
- `deletedAt` TIMESTAMP  // 软删除时间标记

### 关系
- `template` 多对一关系指向 PlanTemplate  // 关联的计划模板
- `block` 多对一关系指向 PlanBlockInstance  // 所属的区间实例

## 5. 类别表 (Category)

### 属性
- `id` UUID PRIMARY KEY  // 类别的唯一标识符
- `name` VARCHAR(50) NOT NULL  // 类别名称
- `color` VARCHAR(20)  // 类别颜色
- `level` INTEGER DEFAULT 0  // 层级深度，0表示顶级
- `path` VARCHAR(255)  // 完整类别路径
- `isVisible` BOOLEAN DEFAULT true  // 是否显示
- `displayOrder` INTEGER  // 显示顺序
- `createdAt` TIMESTAMP NOT NULL  // 创建时间
- `updatedAt` TIMESTAMP NOT NULL  // 最后更新时间
- `deletedAt` TIMESTAMP  // 软删除时间标记

### 关系
- `parent` 多对一关系指向 Category  // 父类别
- `children` 一对多关系指向 Category  // 子类别

## 三、数据约束（补充）

### 1. 外键约束（补充）
- PlanTemplate.category -> Category.id
- PlanInstance.template -> PlanTemplate.id
- PlanInstance.block -> PlanBlockInstance.id
- Category.parent -> Category.id

### 2. 时间约束（补充）
- PlanInstance: endTime > startTime
- PlanInstance的时间范围必须在其所属PlanBlockInstance的时间范围内

## 四、索引设计（补充）

### PlanTemplate
- idx_plan_template_category (category)  // 用于按类别查找计划模板
- idx_plan_template_name (name)  // 用于按名称快速查找计划模板

### PlanInstance
- idx_plan_instance_template (template)  // 用于查找特定模板的所有实例
- idx_plan_instance_block (block)  // 用于查找特定区间内的所有计划
- idx_plan_instance_date (startTime, endTime)  // 用于日期范围查询

### Category
- idx_category_parent (parent)  // 用于查找子类别
- idx_category_path (path)  // 用于按路径快速查找类别

