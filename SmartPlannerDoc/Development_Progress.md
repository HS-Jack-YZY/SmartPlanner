# SmartPlanner 开发进度记录

## 第一阶段：基础架构搭建

### 3. CoreData模型设计 ✓
- [x] 创建CoreData Model文件 ✓
  - [x] 新建SmartPlanner.xcdatamodeld文件
  - [x] 配置Model Version
- [x] 设计PlanBlockTemplate实体 ✓
  - [x] 创建基础属性
    - [x] id: UUID (PRIMARY KEY)
    - [x] name: String (NOT NULL)
    - [x] color: String (optional)
    - [x] desc: String (optional)
    - [x] isVisible: Boolean (DEFAULT true)
    - [x] createdAt: Date (NOT NULL)
    - [x] updatedAt: Date (NOT NULL)
    - [x] deletedAt: Date (optional)
  - [x] 设置关联关系
    - [x] 与PlanBlockInstance的一对多关系（instances <-> template）
- [x] 设计PlanBlockInstance实体 ✓
  - [x] 创建基础属性
    - [x] id: UUID (PRIMARY KEY)
    - [x] startAt: Date (NOT NULL)
    - [x] endAt: Date (NOT NULL)
    - [x] createdAt: Date (NOT NULL)
    - [x] updatedAt: Date (NOT NULL)
    - [x] deletedAt: Date (optional)
  - [x] 设置关联关系
    - [x] 与PlanBlockTemplate的多对一关系（template <-> instances）
    - [x] 与PlanInstance的一对多关系（planInstances <-> blockInstance）
- [x] 设计PlanTemplate实体 ✓
  - [x] 创建基础属性
    - [x] id: UUID (PRIMARY KEY)
    - [x] name: String (NOT NULL)
    - [x] color: String (optional)
    - [x] isFixedTime: Boolean (DEFAULT false)
    - [x] isReminderEnabled: Boolean (DEFAULT true)
    - [x] reminderTime: Integer (optional)
    - [x] priority: Integer (optional)
    - [x] difficulty: Integer (optional)
    - [x] tags: String (optional)
    - [x] createdAt: Date (NOT NULL)
    - [x] updatedAt: Date (NOT NULL)
    - [x] deletedAt: Date (optional)
  - [x] 设置关联关系
    - [x] 与Category的多对一关系（category <-> planTemplates）
    - [x] 与PlanInstance的一对多关系（planInstances <-> planTemplate）
- [x] 设计PlanInstance实体 ✓
  - [x] 创建基础属性
    - [x] id: UUID (PRIMARY KEY)
    - [x] startTime: Date (NOT NULL)
    - [x] endTime: Date (NOT NULL)
    - [x] duration: Integer (NOT NULL)
    - [x] reminderTime: Integer (optional)
    - [x] priority: Integer (optional)
    - [x] difficulty: Integer (optional)
    - [x] createdAt: Date (NOT NULL)
    - [x] updatedAt: Date (NOT NULL)
    - [x] deletedAt: Date (optional)
  - [x] 设置关联关系
    - [x] 与PlanTemplate的多对一关系（planTemplate <-> planInstances）
    - [x] 与PlanBlockInstance的多对一关系（blockInstance <-> planInstances）
- [x] 设计Category实体 ✓
  - [x] 创建基础属性
    - [x] id: UUID (PRIMARY KEY)
    - [x] name: String (NOT NULL)
    - [x] color: String (optional)
    - [x] level: Integer 16 (DEFAULT 0)
    - [x] path: String (optional)
    - [x] isVisible: Boolean (DEFAULT true)
    - [x] displayOrder: Integer 16 (optional, DEFAULT 0)
    - [x] createdAt: Date (NOT NULL)
    - [x] updatedAt: Date (NOT NULL)
    - [x] deletedAt: Date (optional)
  - [x] 设置关联关系
    - [x] 设置parent关系（自引用，多对一）
      - [x] Destination: Category
      - [x] Optional: YES
      - [x] To Many: NO
      - [x] Deletion Rule: Nullify
      - [x] 设置Inverse: children
    - [x] 设置children关系（自引用，一对多）
      - [x] Destination: Category
      - [x] Optional: YES
      - [x] To Many: YES
      - [x] Deletion Rule: Cascade
      - [x] 设置Inverse: parent
    - [x] 与PlanTemplate的一对多关系（planTemplates <-> category）

## 下一步工作计划
1. 生成NSManagedObject子类
2. 实现CoreData Stack
3. 编写CRUD操作的基础代码