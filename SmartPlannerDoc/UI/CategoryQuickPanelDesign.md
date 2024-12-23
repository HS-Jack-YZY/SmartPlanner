# 计划类别快捷面板设计规范

## 一、概述

### 1. 设计目标
- 提供快速访问计划类别的入口
- 保持界面简洁直观
- 确保操作便捷高效
- 符合iOS底部面板设计规范

### 2. 使用场景
- 通过底部导航栏"类别"按钮触发
- 快速查看和选择计划类别
- 快速创建新类别

## 二、界面规范

### 1. 布局结构
```
┌──────────────────────────────────────────────────────┐
│                    拖动条区域 (20pt)                  │
├──────────────────────────────────────────────────────┤
│                                                      │
│                     列表区域                         │
│                 (动态高度，可滚动)                    │
│                                                      │
├──────────────────────────────────────────────────────┤
│  [+]  新增类别                                       │
└──────────────────────────────────────────────────────┘
```

### 2. 尺寸规范

#### 2.1 面板尺寸
- 高度：屏幕高度的 1/3
- 宽度：全屏宽度
- 圆角：顶部 13pt

#### 2.2 内部元素
- 拖动条：
  - 宽度：36pt
  - 高度：5pt
  - 圆角：2.5pt
- 列表项高度：44pt
- 新增按钮：
  - 高度：44pt
  - 图标尺寸：22pt

### 3. 间距规范
- 面板边距：16pt
- 拖动条上下间距：8pt
- 列表项间距：0pt（紧凑布局）
- 底部安全区域：根据设备自适应

## 三、视觉规范

### 1. 颜色方案
- 面板背景：systemBackground
- 拖动条：tertiaryLabel
- 分割线：separator
- 新增按钮：
  - 图标：primary
  - 文字：primary

### 2. 模糊效果
- 背景模糊：systemThickMaterial
- 模糊强度：regular

### 3. 阴影效果
- 面板阴影：
  - 颜色：black
  - 透明度：0.1
  - 偏移：y = -2pt
  - 模糊：10pt

## 四、交互规范

### 1. 手势操作

#### 1.1 拖动条手势
- **下滑手势**：
  - 触发阈值：下滑距离 > 20pt
  - 过程动画：面板跟随手指位置，透明度渐变
  - 完成条件：下滑速度 > 300pt/s 或下滑距离 > 面板高度的 30%
  - 结果：退出快捷面板，恢复底部工具栏状态
  - 取消条件：下滑距离不足且速度较慢时，回弹到原位

- **上滑手势**：
  - 触发阈值：上滑距离 > 20pt
  - 过程动画：面板跟随手指位置，逐渐展开
  - 完成条件：上滑速度 > 300pt/s 或上滑距离 > 面板高度的 30%
  - 结果：进入计划类别详细界面（全屏）
  - 取消条件：上滑距离不足且速度较慢时，回弹到原位

- **动画参数**：
  ```
  过渡动画：
  - 时长：0.3秒
  - 曲线：spring(response: 0.3, dampingFraction: 0.8)
  - 速度跟随：根据手势速度调整动画速度
  
  回弹动画：
  - 时长：0.2秒
  - 曲线：spring(response: 0.2, dampingFraction: 0.6)
  ```

#### 1.2 触感反馈
- 开始拖动：light impact
- 越过阈值：medium impact
- 完成转场：soft impact
- 取消回弹：light impact

#### 1.3 状态指示
- **下滑状态**：
  - 透明度：根据下滑距离渐变（1.0 -> 0.0）
  - 缩放：略微缩小（scale: 1.0 -> 0.95）
  
- **上滑状态**：
  - 背景模糊：渐变增强
  - 阴影：渐变加深
  - 圆角：逐渐消失

#### 1.4 列表手势
- 点击：选择类别
- 左滑：快速操作（可选）
- 长按：触感反馈

### 2. 动画效果

#### 2.1 展示动画
- 动画曲线：spring(response: 0.3, dampingFraction: 0.8)
- 动画时长：0.3秒
- 配合键盘高度动态调整

#### 2.2 交互动画
- 按钮点击：scale(0.96)
- 列表项选中：highlight
- 拖动反馈：实时跟随

### 3. 触感反馈
- 面板出现：soft impact
- 按钮点击：light impact
- 列表选中：selection

## 五、状态管理

### 1. 面板状态
- 折叠状态：隐藏
- 展开状态：显示
- 过渡状态：动画中

### 2. 列表状态
- 空状态：显示提示文本
- 加载状态：显示加载指示器
- 错误状态：显示错误提示

## 六、辅助功能

### 1. 可访问性
- VoiceOver支持
- 动态字体适配
- 减少动效支持
- 高对比度支持

### 2. 设备适配
- iPhone各尺寸适配
- 安全区域适配
- 横竖屏适配（可选）

## 七、性能优化

### 1. 列表优化
- 使用 UICollectionView 实现
- 启用cell复用
- 预加载机制
- 平滑滚动

### 2. 动画优化
- 硬件加速
- 避免离屏渲染
- 优化刷新机制

## 八、测试要点

### 1. 功能测试
- 面板展示/隐藏
- 列表滚动流畅度
- 新增按钮响应
- 手势识别准确性

### 2. 兼容性测试
- 不同iOS版本
- 不同设备尺寸
- 不同系统设置

## 九、注意事项

### 1. 开发建议
- 使用 UISheetPresentationController
- 实现 UIViewControllerTransitioningDelegate
- 注意内存管理
- 处理键盘遮挡

### 2. 常见问题
- 手势冲突处理
- 动画卡顿优化
- 内存泄漏预防
- 异常状态恢复

## 十、更新记录

### 1.0.0 (2024-12-20)
- 初始设计规范创建
- 完整的交互设计
- 详细的视觉规范
- 性能优化建议 