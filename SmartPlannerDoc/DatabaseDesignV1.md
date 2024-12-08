# SmartPlanner 数据库设计

## 1. 计划区间模板表 (PlanBlockTemplate)

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
- `id` UUID PRIMARY KEY  // 计划���板的唯一标识符
- `name` VARCHAR(100) NOT NULL  // 计划模板名称，如"背单词"、"写代码"
- `categoryId` UUID REFERENCES Category(id)  // 关联的类别ID，默认为"默认"
- `color` VARCHAR(20)  // 在日历视图中显示的颜色，来自类别表
- `isFixedTime` BOOLEAN DEFAULT false  // 是否为固定时间计划，false表示AI可调整时间
- `isReminderEnabled` BOOLEAN DEFAULT true  // 是否启用提醒，选填
- `reminderTime` INTEGER  // 提前提醒时间（分钟），选填
- `priority` INTEGER  // 优先级（1-5，5最高），选填
- `difficulty` INTEGER  // 难度等级（1-5，5最难），选填
- `tags` VARCHAR(50)[]  // 标签数组，用于分类和筛选，选填
- `createdAt` TIMESTAMP NOT NULL  // 创建时间
- `updatedAt` TIMESTAMP NOT NULL  // 最后更新时间
- `deletedAt` TIMESTAMP  // 软删除时间标记

## 4. 计划实例表 (PlanInstance)

### 属性
- `id` UUID PRIMARY KEY  // 计划实例的唯一标识符
- `templateId` UUID REFERENCES PlanTemplate(id)  // 关联的计划模板ID
- `blockId` UUID REFERENCES PlanBlockInstance(id)  // 所属区间实例ID
- `name` VARCHAR(100) NOT NULL  // 计划实例名称
- `categoryId` UUID REFERENCES Category(id)  // 关联的类别ID，默认为"默认"
- `startTime` TIMESTAMP NOT NULL  // 计划开始时间
- `endTime` TIMESTAMP NOT NULL  // 计划结束时间
- `duration` INTEGER NOT NULL  // 计划持续时长（分钟）
- `reminderTime` INTEGER  // 提醒时间（可覆盖模板设置），选填
- `priority` INTEGER  // 优先级（1-5，5最高）（可覆盖模板设置），选填
- `difficulty` INTEGER  // 难度等级（1-5，5最难）（可覆盖模板设置），选填
- `tags` VARCHAR(50)[]  // 标签数组，用于分类和筛选（可覆盖模板设置），选填
- `createdAt` TIMESTAMP NOT NULL  // 创建时间
- `updatedAt` TIMESTAMP NOT NULL  // 最后更新时间
- `deletedAt` TIMESTAMP  // 软删除时间标记

## 5. 类别表 (Category)

### 属性
- `id` UUID PRIMARY KEY  // 类别的唯一标识符
- `name` VARCHAR(50) NOT NULL  // 类别名称，如"学习"、"工作"、"运动"
- `color` VARCHAR(20)  // 类别颜色
- `parentId` UUID REFERENCES Category(id)  // 父类别ID，用于构建类别层级
- `level` INTEGER DEFAULT 0  // 层级深度，0表示顶级类别
- `path` VARCHAR(255)  // 完整类别路径，如"学习/英语/词汇"
- `isVisible` BOOLEAN DEFAULT true  // 是否在界面中显示
- `displayOrder` INTEGER  // 显示顺序
- `createdAt` TIMESTAMP NOT NULL  // 创建时间
- `updatedAt` TIMESTAMP NOT NULL  // 最后更新时间
- `deletedAt` TIMESTAMP  // 软删除时间标记

## 索引设计

### PlanBlockTemplate
- idx_block_template_name (name)  // 用于按名称快速查找区间模板

### PlanBlockInstance
- idx_block_instance_template (templateId)  // 用于查找特定模板的所有实例
- idx_block_instance_date (startAt, endAt)  // 用于日期范围查询

### PlanTemplate
- idx_plan_template_category (categoryId)  // 用于按类别查找计划模板
- idx_plan_template_name (name)  // 用于按名称快速查找计划模板

### PlanInstance
- idx_plan_instance_template (templateId)  // 用于查找特定模板的所有实例
- idx_plan_instance_block (blockId)  // 用于查找特定区间内的所有计划
- idx_plan_instance_date (startTime, endTime)  // 用于日期范围查询
- idx_plan_instance_recurrence_group (recurrenceGroupId)  // 用于快速查找同一组的重复计划
- idx_plan_instance_sequence (recurrenceGroupId, recurrenceSequence)  // 用于按序列顺序查找计划

### Category
- idx_category_parent (parentId)  // 用于查找子类别
- idx_category_path (path)  // 用于按路径快速查找类别
