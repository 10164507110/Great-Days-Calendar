## 2018 - 12 - 29

---
## note
- 主要的id
    + 日历本体：calendar
    + 左下显示的主区域：main-zone
    + 右侧列表整体：right-list
    + 用户与logo：logo-zone
    + 我的群组：myGroups
    + 我的计划：myPlans

- 主要的类
    + 整体区域：main

---
## 下拉列表
- 目前主要是用angular简单控制的下拉列表，请翔酱好好改改样式哦！
- 样式表(css文件)的命名为 XXX(什么东西，日历还是我的群组还是我的计划)-XX(在哪里，main还是list，main指的是坐下的大大的主区域，list指的是右侧列表栏)
- 所以我的群组现在的样式在calendar/css/myGroups-list.css 我的计划现在的样式是calendar/css/myPlans-list.css 样式表的结构可以看我的css/calendar-main.css,尽量统一风格，有组织点。或者你先自己写，我到时候统一组织下。
- 目前的数据是伪数据。在dart文件(calendar/calendar_component.dart)的class CalendarComponent的前面有用注释围起来的伪数据区域。

## 需要内容
- 确定数据库我的计划-时间的存法，需要计算日期，例如还剩多少天
- 研究下登陆界面
- 研究下弹出框



