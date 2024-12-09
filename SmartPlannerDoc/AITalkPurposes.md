继续补充逻辑：
1: 用户可以先创建一个“计划区间模版”，命名该模版区间的名称为“工作时间”并指定他的颜色为紫色。
2: 将“工作时间”计划区间模版拖到日历视图上，生成一个“计划区间实例”。
3: 用户点击日历视图上的计划区间实例，可以设置它的范围是周一到周五的早上8点到下午5点。这样就会生成另外四个“计划区间实例”，每周就会有五个名为“工作时间”的计划区间实例。
4: 用户在“类别”模块中添加了一个“英语类别”颜色为蓝色，又在“英语类别”中添加了一个子类为“雅思”颜色为浅蓝色。“类别”模块可以在“数据分析”模块中使用，比如查看一周里不同类别的时间和效率。
5: 用户创建一个计划模版，命名为“雅思阅读”将它的类别设置为“英语”，也可以设置它的提前提醒时间，并且默认它为非固定时间计划（说明ai可以灵活调整这个计划的时间）。
6: 用户将“雅思阅读”计划模版拖动到日历视图中的某个“计划区间”中，会在该计划区间生成一个“计划实例”。
7: 用户可以重复拖动“雅思阅读”计划模版到日历视图中，也可以点击日历视图中的某个“雅思阅读”计划实例，设置该计划的重复时间。
8: 用户可以点击日历视图某个“雅思阅读”计划实例，重构它的提醒时间，那么只有该计划实例的提醒时间变化了，其他仍然继承计划模版的提醒时间。

用户可以创建两个计划区间可以分别命名为“工作区间”和“个人区间”，在“日历视图”不同时间分别创建“工作区间”和“个人区间”后，用户可以将“学习雅思”“学数学”等与工作相关的计划拖动到“工作区间”中，将“跑步”“玩游戏”等与工作无关的计划拖动到“个人区间”中。这些区间会智能管理在区间中的计划实例，如“雅思学习”比预期时间多花了30分钟，那么可能会将后续计划压缩或移动到下一个“工作区间”中。

用户在今天8:00-9:00有一个“学习雅思”计划。app会提供几个选项“开始”“跳过”“延后”，“开始”指app开始记录用户正在执行计划；“跳过”指用户今天不执行这个计划了；“延后”指用户将这个计划延后到将来做。
用户按下“开始”后，app记录该计划的开始时间，app中也会显示该计划的持续时间。在计划进行状态下，用户可以选择”暂停“”完成“。”暂停“则进入暂停状态，”完成“则会记录停止时间，并标记该计划已完成。
”暂停“状态下会记录暂停的开始时间，也会显示暂停的持续时间。在”暂停“状态下，用户可以选择”继续“”完成“。”继续“则代表继续该计划，记录暂停的结束时间；”完成“则代表该计划完成。



@ProjectStructure.md @DevelopmentGuideV1.md @DatabaseDesignV1.md @prdV1.md @tddV1.md @DevelopmentProgress.md ，我列出的文件都是非常重要的文档，请协助我开发SmartPlanner。在我的项目结构发生变化时，请及时更新 @ProjectStructure.md ；当开发进度向前推进时请更新 @DevelopmentProgress.md 。

请更新 @ProjectStructure.md 文件。请记住，在项目目录、文件发生变动时，需要及时更新 @ProjectStructure.md 文件。

我需要你提醒我，作为一个经验丰富的ios开发者何时应该向git仓库commit，并给我commit的内容。要求如下：
Now, please generate a commit message with Chinese.
Make sure it includes an accurate and informative subject line that succinctly summarizes the key points of the changes, the response must only have commit message content and must have blank line in message template.

Below is the commit message template:

<type>(<scope>): <subject>
// blank line
<body>
// blank line
<footer>

The Header is mandatory, while the Body and Footer are optional.

Regardless of which part, no line should exceed 72 characters (or 100 characters). This is to avoid automatic line breaks affecting aesthetics.

Below is the type Enum:

- feat: new feature
- fix: bug fix
- docs: documentation
- style: formatting (changes that do not affect code execution)
- refactor: refactoring (code changes that are neither new features nor bug fixes)
- test: adding tests
- chore: changes to the build process or auxiliary tools

The body section is a detailed description of this commit and can be split into multiple lines. Here's an example:

More detailed explanatory text, if necessary. Wrap it to about 72 characters or so. 

Further paragraphs come after blank lines.

- Bullet points are okay, too
- Use a hanging indent