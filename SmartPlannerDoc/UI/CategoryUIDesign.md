# SmartPlanner 计划类别 UI 设计文档

## 一、设计原则

### 1. 设计理念
- **简约性**：遵循 Apple 简约设计风格，减少视觉干扰
- **一致性**：与 iOS 系统设计保持一致
- **直观性**：用户无需学习即可理解的交互方式
- **层级性**：清晰的视觉层级和信息架构
- **可用性**：优先考虑用户体验和易用性

### 2. 设计目标
- 提供清晰的类别管理界面
- 支持多层级类别组织
- 简化类别创建和管理流程
- 确保视觉美观和功能实用的平衡
- 优化移动端操作体验

## 二、视觉规范

### 1. 颜色系统

#### 1.1 主题色
- **主色调**：采用 iOS 系统蓝色
- **强调色**：用于重要操作和状态提示
- **背景色**：
  - 浅色模式：纯白背景
  - 深色模式：深色背景
  - 次级背景：略微偏灰

#### 1.2 文本色
- **主要文本**：黑色/白色（根据模式自适应）
- **次要文本**：系统灰色
- **链接文本**：系统蓝色
- **警示文本**：系统红色

#### 1.3 功能色
- **成功状态**：系统绿色
- **警告状态**：系统黄色
- **错误状态**：系统红色
- **信息提示**：系统蓝色

### 2. 字体规范

#### 2.1 标题字体
- **大标题**：SF Pro Display, 34pt, Bold
- **页面标题**：SF Pro Display, 22pt, Semibold
- **分区标题**：SF Pro Text, 17pt, Semibold
- **列表标题**：SF Pro Text, 17pt, Regular

#### 2.2 正文字体
- **主要文本**：SF Pro Text, 17pt, Regular
- **次要文本**：SF Pro Text, 15pt, Regular
- **辅助文本**：SF Pro Text, 13pt, Regular
- **标签文本**：SF Pro Text, 12pt, Regular

### 3. 间距规范

#### 3.1 外边距
- **页面边距**：16pt
- **分区边距**：16pt
- **列表边距**：16pt
- **卡片边距**：16pt

#### 3.2 内边距
- **内容内边距**：16pt
- **列表项内边距**：12pt
- **按钮内边距**：12pt
- **图标文本间距**：8pt

#### 3.3 元素间距
- **分区间距**：20pt
- **列表项间距**：8pt
- **相关元素间距**：8pt
- **无关元素间距**：16pt

### 4. 图标规范

#### 4.1 系统图标
- **导航栏图标**：22pt
- **工具栏图标**：22pt
- **列表图标**：20pt
- **操作图标**：18pt

#### 4.2 自定义图标
- **类别标记**：12pt
- **状态图标**：16pt
- **提示图标**：14pt
- **装饰图标**：根据具体场景定义

## 三、界面布局

### 1. 导航栏设计
- **标题**：显示"计划类别"
- **左侧**：返回按钮（如果在导航栈中）
- **右侧**：添加新类别按钮
- **样式**：使用大标题样式

### 2. 主列表视图

#### 2.1 列表项布局
- **左侧**：类别颜色标识
- **中间**：类别名称
- **右侧**：子类别数量和箭头
- **缩进**：根据层级自动缩进

#### 2.2 空状态设计
- **中心图标**：使用网格或文件夹图标
- **提示文本**：友好的空状态提示
- **操作按钮**：快速添加类别的入口

### 3. 编辑视图

#### 3.1 基本信息区
- **类别名称**：文本输入框
- **类别颜色**：颜色选择器
- **可见性**：开关控件
- **父类别**：选择器（非顶级类别）

#### 3.2 高级设置区
- **显示顺序**：数字调节器
- **层级信息**：当前层级显示
- **模板关联**：关联计划模板列表

#### 3.3 操作区域
- **保存按钮**：主要操作
- **取消按钮**：次要操作
- **删除按钮**：警示操作（编辑模式）

## 四、交互设计

### 1. 手势操作

#### 1.1 基础手势
- **点击**：进入详情或展开/折叠
- **长按**：激活拖拽排序
- **左滑**：显示快捷操作菜单
- **右滑**：返回上级（如适用）

#### 1.2 编辑手势
- **拖拽排序**：调整显示顺序
- **拖拽层级**：调整类别层级
- **滑��删除**：快速删除类别

### 2. 动画效果

#### 2.1 过渡动画
- **视图切换**：平滑过渡
- **展开/折叠**：自然动画
- **层级调整**：流畅变化
- **状态更新**：渐变效果

#### 2.2 反馈动画
- **操作确认**：轻微缩放
- **删除动作**：滑出效果
- **错误提示**：晃动效果
- **加载状态**：旋转动画

### 3. 状态反馈

#### 3.1 视觉反馈
- **选中状态**：高亮显示
- **拖拽状态**：半透明效果
- **禁用状态**：灰度处理
- **错误状态**：红色提示

#### 3.2 触感反馈
- **操作确认**：轻触反馈
- **错误提示**：错误触感
- **拖拽开始**：轻微触感
- **拖拽结束**：完成触感

## 五、辅助功能

### 1. 可访问性

#### 1.1 视觉辅助
- **动态字体**：支持系统字体大小调节
- **高对比度**：支持高对比度模式
- **减少动效**：支持减少动画设置
- **颜色标签**：提供颜色名称描述

#### 1.2 听觉辅助
- **VoiceOver**：完整的语音描述
- **操作提示**：清晰的语音反馈
- **状态变化**：状态更新提示
- **错误通知**：错误信息播报

### 2. 操作辅助

#### 2.1 键盘操作
- **快捷键支持**：常用操作快捷键
- **键盘导航**：完整的键盘控制
- **聚焦提示**：清晰的聚焦��态
- **回车确认**：支持回车快捷操作

#### 2.2 替代操作
- **语音控制**：支持语音命令
- **开关控制**：支持开关控制
- **手势替代**：提供替代手势
- **快捷指令**：支持系统快捷指令

## 六、响应式设计

### 1. 设备适配

#### 1.1 iPhone适配
- **标准尺寸**：优化标准iPhone显示
- **小屏幕**：适配小屏iPhone
- **大屏幕**：利用大屏空间
- **刘海屏**：适配安全区域

#### 1.2 iPad适配（未来）
- **分屏支持**：支持iPad分屏
- **浮动窗口**：支持多窗口操作
- **键盘支持**：优化键盘操作
- **Pencil支持**：支持手写输入

### 2. 方向适配

#### 2.1 竖屏布局
- **标准布局**：优化竖屏显示
- **列表视图**：垂直滚动列表
- **编辑视图**：全屏编辑模式
- **键盘适配**：自动调整布局

#### 2.2 横屏布局（未来）
- **双栏布局**：利用横向空间
- **并排显示**：类别列表与详情
- **快捷操作**：优化横屏操作
- **工具栏**：额外功能入口

## 七、性能考虑

### 1. 列表优化

#### 1.1 加载优化
- **延迟加载**：按需加载内容
- **分页加载**：大量数据分页
- **预加载**：智能预加载
- **缓存机制**：本地数据缓存

#### 1.2 滚动优化
- **复用机制**：列表项复用
- **按需渲染**：可视区域渲染
- **图片优化**：图片懒加载
- **动画优化**：滚动时优化

### 2. 状态管理

#### 2.1 数据状态
- **增量更新**：支持部分更新
- **状态同步**：多视图状态同步
- **错误恢复**：异常状态恢复
- **本地持久化**：状态持久化

#### 2.2 交互状态
- **即时反馈**：操作即时响应
- **状态缓存**：临时状态缓存
- **批量更新**：批量操作优化
- **状态回滚**：支持操作撤销

## 八、测试要点

### 1. 功能测试

#### 1.1 基础功能
- **创建类别**：验证创建流程
- **编辑类别**：验证编辑功能
- **删除类别**：验证删除操作
- **排序功能**：验证排序效果

#### 1.2 高级功能
- **层级管理**：验证层级调整
- **批量操作**：验证批量功能
- **数据同步**：验证同步机制
- **状态恢复**：验证恢复功能

### 2. 兼容性测试

#### 2.1 设备兼容
- **不同设备**：各种设备测试
- **不同系统**：系统版本测试
- **不同分辨率**：显示适配测试
- **不同语言**：本地化测试

#### 2.2 功能兼容
- **网络状态**：各种网络环境
- **存储空间**：不同存储条件
- **后台运行**：后台状态处理
- **中断恢复**：中断后恢复

## 九、发��检查清单

### 1. 设计检查

#### 1.1 视觉检查
- **设计规范**：符合设计规范
- **视觉一致**：保持视觉一致
- **色彩对比**：足够的对比度
- **字体规范**：符合字体规范

#### 1.2 交互检查
- **操作流畅**：流畅的交互体验
- **反馈及时**：及时的状态反馈
- **无死角**：完整的交互覆盖
- **容错处理**：合理的容错机制

### 2. 功能检查

#### 2.1 核心功能
- **基础操作**：创建、编辑、删除
- **数据同步**：数据同步正常
- **状态管理**：状态管理正确
- **性能表现**：性能达标

#### 2.2 辅助功能
- **可访问性**：辅助功能完整
- **本地化**：本地化支持完整
- **异常处理**：异常处理得当
- **帮助信息**：帮助信息完整

## 十、更新记录

### 1.0.0 (2024-12-20)
- 初始设计文档创建
- 完整的UI设计规范
- 详细的交互设计说明
- 完整的辅助功能支持方案

## 十一、附录

### 1. 参考资料
- Apple Human Interface Guidelines
- iOS Design Patterns
- Accessibility Guidelines
- Material Design (参考)

### 2. 相关文档
- 产品需求文档
- 技术架构文档
- API设计文档
- 测试用例文档 