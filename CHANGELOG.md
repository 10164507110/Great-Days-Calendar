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


##1/2日志——周嘉翔
    19:40更新：花了几天时间找控件、升级SDK以及在无意义的dubug上，我现在很烦躁。正式的方面还没开始弄，我打算之后等辅修考完把数据库链接弄好，或者在今晚。现在传上来的只有一个几乎没什么改动的版本，只有css样式和少的可怜的dart语句有变动，这就像去逛街逛了一整天最终还是啥也没买只好把身上本来穿的衣服洗洗干净一样，看起来外表没什么变化，但是人很受折磨。不想多说了。
    pubspec.yaml文件用之前传的那份，我升级到2.1回不去了，所以就和你们暂时不一样，祝我能找到合适的控件吧。
    0:48分更新：我搞不明白该怎么用控件，我已经花了数小时在这个蠢问题上了，现在我十分恼火。我不会再花时间搞控件的问题了，界面丑就丑吧。


##关于登录/注册
- 目前实现登录+注册+跳转至calendar，登录注册还有部分数据验证没写，等邮箱跑通一起写。
- 现在基本搞明白服务器，客户端之间怎么连接了。之后可以帮康康那部分改一下连接数据库的部分。
- 下一步准备研究一下cookie（最后再说吧）。
- 登录可用用户名：admin 密码：abc123abc123
- 找到可用邮箱package，但是之间pub get的那个发得很慢，所以我直接把那整个包拷过来了。方法存在send_ecnustumail里面，后面直接复制粘贴用就好了。


## 关于计算公共时间
- 先根据选中的群组抽取出当前群组的成员一个members数组
- 从beginDate 开始到endDate 扫描每一天
- 该天有1440 这是一个分钟数组，一开始每一分钟都是0(未被占用时间)
- for mem in members{} 扫描每一个成员
    for plan in plans{} 扫描该mem的plans数组
        if plantype is interval//先处理时间段
            if nowdate during plandate// 挖去占用时间 标记为1
- 此时有该天剩余时间段(数组中连续标0的段落)，把这些段落整合成Result(nowdate, beginTime, endTime)
- 此时需要根据是否满足limitDelta的要求，来将Result推入临时的Result数组(今日的)
- for mem in members{} 重新扫描
    for plan in plans{} 
        if plantype is point
            for result in 临时的Result数组
                if pointTime between thisResult's bound
                    this.Result. 在这个Result记录下(who when what)
                    
- 把今天的临时Result的值推入最终的解里
