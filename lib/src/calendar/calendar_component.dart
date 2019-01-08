import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'dart:html';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:angular_router/angular_router.dart';



@Component(
  selector: 'calendar',
  styleUrls: ['calendar_component.css'],
  templateUrl: 'calendar_component.html',
  directives: [
    materialInputDirectives,
    MaterialFabComponent,
    MaterialButtonComponent,
    MaterialRadioComponent,
    MaterialRadioGroupComponent,
    NgFor,
    NgIf,
    routerDirectives,
  ],
)

class CalendarComponent{
  /*------------------- instance variables --------------------*/
  /*------------- 日历相关变量 ------------------*/
  List<int> days = new List<int>.filled(42, -1);
  List<String> day_color = new List<String>.filled(42, "lightgrey");//日历上日期的颜色
  List<int> month_day = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  List<bool> hasEvent = new List<bool>.filled(42, false);
  List<String> eventColor = new List<String>.filled(42, "plancolor-");//日历上圆点的颜色
  String selectDate = '';
  int now_day, now_month, now_year;


  /*----- 我的群组有关的变量 -------*/
  bool groupsFlag = false;//默认我的群组展开
  bool addGroupFlag = false;//默认添加群组选项隐藏
  bool changeGroupStatus = false;//默认对群组改动选项隐藏
  // bool addGroupFlag = true;//默认加入群组选项展开
  

  /*----- 我的计划有关的变量 -------*/
  List<String> plancolor = [];
  List<String> dotOrDash = [];
  List<String> hovercolor = new List<String>.filled(42, "hovercolor-");
  final int COLORNUM = 18;//默认的颜色数目
  bool plansFlag = true;//默认我的计划展开
  bool showPlan = false;//是否显示表单
  bool submit = false;//是否提交过
  bool submitWarning = false;

  String planname = '';//计划名称
  String plantype = '';//时间点/时间段

  String plandatePoint = '';//日期信息
  String plantimePoint = '';//具体的时间
  String plandateBegin = '';//日期信息(时间段起点)
  String plantimeBegin = '';//具体的时间
  String plandateEnd = '';//日期信息(时间段终点)
  String plantimeEnd = '';//具体的时间

  String groupName = '';//新添加的群组名称

  String myName = "stupig";//我的用户名
  List<Group> mygroups = [];//我的群组
  List<Plan> myplans = [];//我的计划


  /*----- 计算公共时间有关的变量 -------*/
  bool commonTimeFlag = false;//默认这个区域不展开
  bool commonTimeResultFlag = true;//true是不显示，false是显示！
  String selectGroup = '';
  String beginDate = "", endDate = "";
  String beginTime = "", endTime = "";
  /*公共时间的结果*/
  static int limitDelta = 30;//结果的默认时段超过30分钟
  int resultNum;
  List<String> dates = [];//form beginDate to endDate;

      /* ----------- 伪数据库 ----------- */
          List<User> users = [];
          List<Group> groups = [];

      /* ------------------------------- */



  //constructor
  CalendarComponent(){
    //创建伪数据 - 测试用
    createTheFakeDatas();
    //填充伪数据给mygroups - 测试用
    fillMygroups();
    //填充伪数据给myplans - 测试用
    fillMyplans();

    //初始化将日历设置成当日
    DateTime now = new DateTime.now();
    now_day = now.day;
    now_month = now.month;
    now_year = now.year;
    calendarUpdate();
  }









  /*---------------------------methods---------------------------*/
  void sendEmail(){
    var client = new http.Client();
    var url = "http://localhost:8002/senddeademail";
    var body = json.encode(
        {"mailbox":"707132127@qq.com", "daealine": 5});
    var headers = {
      "content-type": "application/json"
    };

    client.post(
        url,
        headers: headers,
        body: body)
        .then((response) {
      if (response.statusCode == 200) {
        window.alert("发送成功");
      }
      else
        window.alert("发送失败");
    })
        .whenComplete(client.close);
  }








  /*--------------------------- 日历本体相关 -------------------------------*/
  //更新日历
  void calendarUpdate(){
    DateTime firstday = new DateTime.utc(now_year, now_month, 1);
    int first_weekday = firstday.weekday;

    int now_pos = first_weekday % 7;
    days[now_pos] = 1;
    leapYear(now_year);

    //将颜色恢复成默认的灰色
    for(int i = 0; i < day_color.length; i++){
      day_color[i] = "lightgrey";
    }

    //填上这个月的日期，并设为黑色
    day_color[now_pos] = "black";
    for(int i = now_pos + 1, j = 2; j <= month_day[now_month]; i++, j++){
      days[i] = days[i-1] + 1;
      day_color[i] = "black";
    }

    //日历上的上个月的日期，设为灰色(默认)
    int last_month = (now_month - 1 > 0) ? now_month-1 : 12;
    for(int i = now_pos - 1, j = 0; i >= 0; i--, j++){
      days[i] = month_day[last_month] - j;
    }

    //日历上的下个月的日期，设为灰色(默认)
    // int next_month = (now_month + 1) % 12;
    for(int i = now_pos + month_day[now_month], j = 1; i < 42; i++){
      days[i] = j++;
    }
    
    //将本日设为绿色并加粗
    DateTime today = new DateTime.now();
    if(now_year==today.year && now_month==today.month){
      day_color[now_pos + today.day - 1] = "today";
    }

    clearEvent();//先清空事件
    //将我的计划里的计划按时间标记出来
    myplanUpdate();

    commonTimeUpdate();//将计算公共时间区域的变量更新

  }//close calendarUpdate()


  //根据我的计划里的计划，给日期增加事件标记(时间点)
  void clearEvent(){
    for(int i=0; i<42; i++){
      eventColor[i] = "plancolor-";
      hasEvent[i]  =false;
    }
  }

   //根据我的计划里的计划，给日期增加事件标记(时间点)
  void myplanUpdate(){
    for(int i=0; i<myplans.length; i++){
      if(myplans[i].plantype == "point"){
        String date = myplans[i].plandatePoint;
        //2019-01-03
        String yearStr = date.substring(0,4);
        String monthStr = date.substring(5,7);
        String dayStr = date.substring(8);
        int year = int.parse(yearStr);
        int month = int.parse(monthStr);
        int day = int.parse(dayStr);

        if(year == now_year && month == now_month){
          hasEvent[getDayIndex(day)] = true;
          if(eventColor[getDayIndex(day)] != "plancolor-"){
            for(int j=i-1; j>=0; j--){
              if(myplans[j].plantype=='point' && myplans[j].plandatePoint == date
              || myplans[j].plantype=='interval' && myplans[j].plandateEnd == date)
                plancolor[j] = planColor(i);
            }//end for
          }//end if(!=plancolor-)
          eventColor[getDayIndex(day)] = planColor(i);
        }
      }else if(myplans[i].plantype == 'interval'){
        String date = myplans[i].plandateEnd;
        //2019-01-03
        String yearStr = date.substring(0,4);
        String monthStr = date.substring(5,7);
        String dayStr = date.substring(8);
        int year = int.parse(yearStr);
        int month = int.parse(monthStr);
        int day = int.parse(dayStr);

        if(year == now_year && month == now_month){
          hasEvent[getDayIndex(day)] = true;
          if(eventColor[getDayIndex(day)] != "plancolor-"){
            for(int j=i-1; j>=0; j--){
              if(myplans[j].plantype=='point' && myplans[j].plandatePoint == date
              || myplans[j].plantype=='interval' && myplans[j].plandateEnd == date)
                plancolor[j] = planColor(i);
            }//end for
          }//end if(!=plancolor-)
          eventColor[getDayIndex(day)] = planColor(i);
        }
      }
    }//end for
  }

  //根据闰年与否修正二月天数
  void leapYear(int year){
    month_day[2] = 
      (year%4==0 &&year%100!=0 || year%400==0) ? 29:28;
  }

  //点击显示前一个月
  void clickPrev(){
    this.now_month -= 1;
    if(this.now_month == 0){
      this.now_month = 12;
      this.now_year -= 1;
    }
    calendarUpdate();
  }

  //点击显示后一个月
  void clickNext(){
    this.now_month += 1;
    if(this.now_month > 12){
      this.now_month = 1;
      this.now_year += 1;
    }
    calendarUpdate();
  }

  //点击refresh按钮，重置日历
  void refresh(){
    DateTime now = new DateTime.now();
    now_day = now.day;
    now_month = now.month;
    now_year = now.year;
    calendarUpdate();
  }

  //返回这一天在这个日历上的index(42以内的数)
  int getDayIndex(int day){
    DateTime firstday = new DateTime.utc(now_year, now_month, 1);
    int first_weekday = firstday.weekday;

    int now_pos = first_weekday % 7;
    return now_pos + day - 1;
  }

  //前往选择的日期
  void gotoSelectDay(){
    if(!selectDate.isEmpty){
      //2019-01-04
      String year = selectDate.substring(0,4);
      String month = selectDate.substring(5,7);
      now_year = int.parse(year);
      now_month = int.parse(month);
      calendarUpdate();
      selectDate = '';
    }
  }














 /* ----------------------- 与我的群组相关的函数 -------------------------------*/  
 //填充“我的群组”的信息给myGroups数组
  void fillMygroups(){
    for(int i=0; i<users.length; i++){
      if(users[i].username == this.myName){
        this.mygroups = users[i].userGroups;
        break;
      }
    }

    // mygroups.add(new Group("pigs"));
  }

  //群组面板中点击+按钮展开群组面板

  void makeChangesToGroups(){
    this.changeGroupStatus=!this.changeGroupStatus;
  }

  void deleteGroupFromMyGroup(Group group){
    mygroups.remove(group);
  }

  void dropDownAddGroupList(){
      this.addGroupFlag = !this.addGroupFlag;
  }

  void addGroupList(){
      if(this.groupName != "")mygroups.add(new Group(this.groupName));
      this.groupName = "";
  }
//  //点击下拉菜单的开头按钮，收回/展开下拉一级菜单
//   void dropDownOptions(String option){
//     switch(option){
//       case 'groupOption':{        
//         this.optionsFlag = !this.optionsFlag;
//         if(!optionsFlag)groupsFlag = optionsFlag;
//         break;
//       }
//     }  
//   }

  //点击下拉菜单的开头按钮，收回/展开下拉二级菜单
  void dropDownList(String target){

    switch(target){
      case 'group':this.groupsFlag = !this.groupsFlag;break;
      case 'plan':this.plansFlag = !this.plansFlag;break;
      case 'common':this.commonTimeFlag = !this.commonTimeFlag;break;
      // case 'addgroup':this.addGroupFlag = !this.addGroupFlag;break;
    }
    // if(target != 'addgroup')
    dropDownListControl(target);
  } 

  void dropDownListControl(String target){
    if(groupsFlag==false && plansFlag==false && commonTimeFlag==false) return;
    else{
      groupsFlag = false;
      plansFlag = false;
      commonTimeFlag = false;
      switch(target){
        case 'group':groupsFlag = true;break;
        case 'plan':plansFlag = true;break;
        case 'common':commonTimeFlag = true;break;
      }
    }
  }















  /* -------------------------- 与我的计划相关的函数 ------------------------------*/
  //填充我的计划(应该从数据库读入)
  void fillMyplans(){

    for(int i=0; i<users.length; i++){
      if(users[i].username == this.myName){
        this.myplans= users[i].userPlans;
        break;
      }
    }
    // myplans.add(new Plan("看JOJO", "interval", "2019-01-07", "18:30", "2019-01-07", "23:30"));
    // myplans.add(new Plan("网络教育应用考试", "interval", "2019-01-10", "15:00", "2019-01-10", "17:00"));
    // myplans.add(new Plan("提交教育测量报告", "point", "2019-01-13", "00:00"));
    // myplans.add(new Plan("闭关复习投资银行学公司财务管理与保险学", "interval", "2019-01-03", "00:00", "2019-01-05", "00:00"));
    // myplans.add(new Plan("做教育游戏", "point", "2019-01-06", "00:00"));
    // myplans.add(new Plan("外出打工，赚钱养家", "interval", "2019-01-05", "18:30", "2019-01-05","20:30"));
    // myplans.add(new Plan("回老家过年！！！", "point", "2019-01-17", "08:30"));


    //设置颜色
    fillPlanColor();
    //设置点/划
    fillPlanType();
  }

  //填充plancolor的数组，并设置颜色(根据是第几个计划)
  void fillPlanColor(){
    plancolor = [];//先清空
    for(int i=0; i<myplans.length; i++){
      int j = i%COLORNUM;
      plancolor.add("plancolor-" + (j+1).toString());
    }
  }

  //填充dotOrDash数组
  void fillPlanType(){
    dotOrDash = [];//先清空
    for(int i=0; i<myplans.length; i++){
      if(myplans[i].plantype == 'point')
        dotOrDash.add('●');
      else
        dotOrDash.add('━━━');
    }
  }

  //根据计划是第几个，选择对应的颜色给原点
  String planColor(int i){
    return "plancolor-" + (i+1).toString();
  }

  //鼠标移到某个计划上
  void enterPlan(int i){
    // dotOrDash[i] = '+';
    String color = plancolor[i];
    if(myplans[i].plantype == "point"){
      //如果是时间点
      String date = myplans[i].plandatePoint;
      //2019-01-03
      String yearStr = date.substring(0,4);
      String monthStr = date.substring(5,7);
      String dayStr = date.substring(8);
      int year = int.parse(yearStr);
      int month = int.parse(monthStr);
      int day = int.parse(dayStr);
      if(now_year == year && now_month == month){
        hovercolor[getDayIndex(day)] = "hovercolor-" + color.substring(10);
      }
    }else{
      //如果是时间段
      String beginDate = myplans[i].plandateBegin, endDate = myplans[i].plandateEnd;
      String yearStr1 = beginDate.substring(0,4), yearStr2 = endDate.substring(0,4);
      String monthStr1 = beginDate.substring(5,7), monthStr2 = endDate.substring(5,7);
      String dayStr1 = beginDate.substring(8), dayStr2 = endDate.substring(8);
      int year1 = int.parse(yearStr1), year2 = int.parse(yearStr2);
      int month1 = int.parse(monthStr1), month2 = int.parse(monthStr2);
      int day1 = int.parse(dayStr1), day2 = int.parse(dayStr2);
      if((year2 > now_year && year1 <= now_year) || (year2 == now_year && month2 >= now_month)){
        for(int j=1; j<=month_day[now_month]; j++){
          if((year1 < now_year) || (year1 == now_year && month1 < now_month)){
            hovercolor[getDayIndex(j)] = "hovercolor-" + color.substring(10);
          }else if(year1 == now_year && month1==now_month){
            if(j >= day1 && month2 > now_month) hovercolor[getDayIndex(j)] = "hovercolor-" + color.substring(10);
            else if(j >= day1 && j <= day2) hovercolor[getDayIndex(j)] = "hovercolor-" + color.substring(10);
          }
        }//end for
      }//end if
    }//end else
  }

  //鼠标移出某个计划
  void leavePlan(int i){
    // dotOrDash[i] = '@@@';
    hovercolor = new List<String>.filled(42, "hovercolor-");
  }

  //显示我的计划表单
  void addPlan(){
    //如果没开，就显示，否则保持显示(保持不变)
    showPlan = (showPlan) ? showPlan:!showPlan;
  }
  
  //清空相关变量
  void clearPlans(){   
    planname = '';//计划名称
    plantype = '';//时间点/时间段
    plandatePoint = ''; plantimePoint = '';
    plandateBegin = ''; plantimeBegin = '';
    plandateEnd = ''; plantimeEnd = '';
  }

  //关闭我的计划表单
  void closePlan(){
    clearPlans();
    submit = false;
    submitWarning = false;
    showPlan = false;
  }

  // 我的计划的表单提交
  void submitPlan(){
    //先检查表单
    if(planname.isEmpty || plantype.isEmpty){
      submitWarning = true;
    }else if(plantype == 'point'){
      submitWarning = (plandatePoint.isEmpty || plantimePoint.isEmpty);
    }else if(plantype == 'interval'){
      submitWarning = (plandateBegin.isEmpty || plandateEnd.isEmpty ||
                       plantimeBegin.isEmpty || plandateEnd.isEmpty);
    }
    //再显示错误警告/关闭菜单
    submit = !submitWarning;
    showPlan = submitWarning;
    
    
    //模拟数据库，写入
    if(this.planname.isNotEmpty && submit){
      // plans.add(planname);
      Plan newplan = null;
      if(this.plantype == 'point'){
        newplan = new Plan(planname, "point", plandatePoint, plantimePoint);
      }else if(this.plantype == 'interval'){
        newplan = new Plan(planname, "interval", plandateBegin, plantimeBegin, plandateEnd, plantimeEnd);
      }
      myplans.add(newplan);
      fillPlanColor();//更新颜色
      fillPlanType();//更新点划
      calendarUpdate();//更新日历
    }
      


    //之后，清空相关变量
    clearPlans();
  }
  









  /* -------------------------- 与计算公共时间相关的函数 ------------------------------*/
  void commonTimeUpdate(){
    //设置默认的beginDate为今天
    DateTime nowtime = new DateTime.now();
    beginDate = nowtime.year.toString() + '-' + (nowtime.month~/10).toString()
        + (nowtime.month%10).toString() + '-' + (nowtime.day~/10).toString()
        + (nowtime.day%10).toString();

    //设置默认的时间段
    beginTime = "10:00"; endTime = "20:00";

  } 

  //监听群组选项的变化
  void changeGroup(String value){
    selectGroup = value;//selectGroup即是当前选中的群组
  }

  //重置公共时间表单
  void resetGreatDay(){
    commonTimeUpdate();
    endDate = "";
  }

  //公共时间表单提交
  void findGreatDay(){
    //先表单检查
    if(selectGroup!="" && beginDate!="" && endDate!=""
        && beginTime!="" && endTime!=""){
          calculateGreatDay();//负责计算出公共时间
          this.commonTimeResultFlag = !this.commonTimeResultFlag;
    }else{
      //可以显示一个警告，表示表单未填完
    }
  }

  //计算公共时间
  void calculateGreatDay(){
    //首先获取当前自己所在的群组
    Group group = null; 
    for(int i=0; i<mygroups.length; i++){
      if(mygroups[i].groupname == selectGroup){
        group = mygroups[i]; 
        break;
      }
    }//end for

    List<User> members = group.groupMembers;
    resultNum = members.length;

    //填充dates数组，从beginDate 到 endDate
    // dates = Datee

  }

  //从结果界面返回表单界面
  void returnGreatDayForm(){
    this.commonTimeResultFlag = !this.commonTimeResultFlag;
  }






  //管理伪数据
  createTheFakeDatas(){
    //myid = stupig happig jumpig sleepig champig 
    //创建了五名角色
    User stupig = new User("stupig");
    User happig = new User("happig");
    User jumpig = new User("jumpig");
    User sleepig = new User("sleepig");
    User champig = new User("champig");

    //填充各自的计划
    /* stupig's plans*/
    stupig.addPlan(new Plan("看JOJO", "interval", "2019-01-07", "18:30", "2019-01-07", "23:30"));
    stupig.addPlan(new Plan("网络教育应用考试", "interval", "2019-01-10", "15:00", "2019-01-10", "17:00"));
    stupig.addPlan(new Plan("提交教育测量报告", "point", "2019-01-13", "00:00"));
    stupig.addPlan(new Plan("闭关复习投资银行学公司财务管理与保险学", "interval", "2019-01-03", "00:00", "2019-01-05", "00:00"));
    stupig.addPlan(new Plan("做教育游戏", "point", "2019-01-06", "00:00"));
    stupig.addPlan(new Plan("外出打工，赚钱养家", "interval", "2019-01-05", "18:30", "2019-01-05","20:30"));
    stupig.addPlan(new Plan("回老家过年！！！", "point", "2019-01-17", "08:30"));
    /* happig's plans*/
    happig.addPlan(new Plan("补《海王》", "point", "2019-01-01", "18:30"));
    happig.addPlan(new Plan("在宿舍补番，拒不开会", "interval", "2019-01-05", "00:00", "2019-01-06", "00:00"));
    happig.addPlan(new Plan("提交教育测量报告", "point", "2019-01-13", "00:00"));
    happig.addPlan(new Plan("去环球港吃喝玩乐", "interval", "2019-01-09", "13:00", "2019-01-09", "20:00"));
    /* jumpig's plans */
    jumpig.addPlan(new Plan("点外卖", "point", "2019-01-07", "12:30"));
    jumpig.addPlan(new Plan("点外卖", "point", "2019-01-08", "12:30"));
    jumpig.addPlan(new Plan("寄快递", "point", "2019-01-15", "14:00"));
    jumpig.addPlan(new Plan("拿快递", "point", "2019-01-07", "13:00"));
    jumpig.addPlan(new Plan("打印报告", "point", "2019-01-12", "14:00"));
    jumpig.addPlan(new Plan("去环球港吃一顿", "interval", "2019-01-09", "13:00", "2019-01-09","20:00"));
    /* sleepig's plans */
    sleepig.addPlan(new Plan("起床吃饭", "point", "2019-01-05", "12:30"));
    sleepig.addPlan(new Plan("睡觉", "interval", "2019-01-05", "13:30", "2019-01-05", "16:00"));
    sleepig.addPlan(new Plan("起床吃饭", "point", "2019-01-05", "16:00"));
    sleepig.addPlan(new Plan("睡觉", "interval", "2019-01-05", "17:00", "2019-01-05", "20:00"));
    sleepig.addPlan(new Plan("起床开黑", "interval", "2019-01-05", "20:00", "2019-01-06", "05:00"));
    sleepig.addPlan(new Plan("睡觉", "interval", "2019-01-05", "13:30", "2019-01-05", "16:00"));
    /* champig's plans */
    champig.addPlan(new Plan("看JOJO", "interval", "2019-01-07", "18:30", "2019-01-07", "23:30"));
    champig.addPlan(new Plan("网络教育应用考试", "interval", "2019-01-10", "15:00", "2019-01-10", "17:00"));
    champig.addPlan(new Plan("提交教育测量报告", "point", "2019-01-13", "00:00"));
    champig.addPlan(new Plan("不明原因外出", "interval", "2019-01-08", "08:00", "2019-01-10", "15:00"));
    champig.addPlan(new Plan("双休日拒不开会", "interval", "2019-01-12", "00:00", "2019-01-13","23:59"));
    champig.addPlan(new Plan("回老家过年！！！", "point", "2019-01-17", "08:30"));

    //填充群组信息
    /*猪组，英汉互译组，2016级教信班委通知群，一起去环球港大吃大喝 */
    Group one = new Group("猪组");
    one.addUser(stupig);one.addUser(happig);one.addUser(jumpig);one.addUser(sleepig);one.addUser(champig);
    Group two = new Group("英汉互译组");
    two.addUser(stupig);two.addUser(happig);two.addUser(jumpig);two.addUser(sleepig);two.addUser(champig);
    Group three = new Group("一起去环球港大吃大喝");
    three.addUser(happig);three.addUser(jumpig);
    Group four = new Group("2016级教信班委群");
    four.addUser(stupig);four.addUser(happig);four.addUser(jumpig);four.addUser(champig);

    stupig.addGroup(one);stupig.addGroup(two);stupig.addGroup(four);
    happig.addGroup(one);happig.addGroup(two);happig.addGroup(three);happig.addGroup(four);
    jumpig.addGroup(one);jumpig.addGroup(two);jumpig.addGroup(three);jumpig.addGroup(four);
    sleepig.addGroup(one);sleepig.addGroup(two);
    champig.addGroup(one);champig.addGroup(two);champig.addGroup(four);

    this.users.add(stupig);this.users.add(jumpig);
    this.users.add(happig);this.users.add(sleepig);this.users.add(champig);
    this.groups.add(one);this.groups.add(two);this.groups.add(three);this.groups.add(four);
    
  }
}













/*
 * 这里的一些类的功能是相关数据在数据库存储的结构相关
 * 在测试阶段，作为伪数据的结构
 * 正式使用时候，应该需要将数据库相关数据读入，并组装成以下这些类进行使用
 */


/* --------------------- 我的计划的类 ----------------------- */
class Plan{
  String planname;
  String plantype;
  String plantimePoint, plandatePoint;
  String plantimeBegin, plantimeEnd;
  String plandateBegin, plandateEnd;
  String username;

  //constructor
  Plan(String planname, String plantype, String date1, String time1, [String date2, String time2]){
    this.planname = planname;
    this.plantype = plantype;

    if(plantype == 'point'){
      this.plandatePoint = date1; this.plantimePoint = time1;
    }else if(plantype == 'interval'){
      this.plandateBegin = date1; this.plantimeBegin = time1;
      this.plandateEnd = date2; this.plantimeEnd = time2;
    }
  }

  // //对于时间段，判断某个日期与这个时间段的关系
  // -2(完全不在) -1 (左边界) 0 (中间) 1(右边界) 2(重叠，就是这天) -3(错误信息)
  int relationDate(String date){
    if(this.plantype != 'interval') return -3;

    if(plandateBegin == plandateEnd){
      if(plandateBegin == date) return 2;
      else return -2;
    }else{
      if(plandateBegin == date) return -1;
      else if(plandateEnd == date) return 1;
      else if(Datee.dateCompare(date, plandateBegin) == 1
        && Datee.dateCompare(date, plandateEnd) == -1) return 0;
      else return -2;
    }
  }

  //对于时间点，判断时间点是否在某个时间范围内 eg. 08:30 ~ 12:30
  bool ifConflict(String begin, String end){
    if(this.plantype != 'point') return false;
    
    if(Datee.timeCompare(this.plantimePoint, begin) >= 0
      && Datee.timeCompare(this.plantimePoint, end) <=0 ){
        return true;
    }else{
      return false;
    }
  }

  //显示改时间点计划的冲突信息
  //格式： XXX(人)-XXXX(事件)-XX:XX(时间点)
  get conflictInfo => username + "-" + this.planname + "-" + this.plantimePoint;
      
}


/* --------------------- 群组的类 ----------------------- */
class Group{
  String groupname;
  List<User> groupMembers;//该群组的用户集合
  
  //constructor
  Group(String groupname){
    this.groupname = groupname;
    this.groupMembers = [];
  }

  void addUser(User user){
    if(user != null && !this.groupMembers.contains(user))
      this.groupMembers.add(user);
  }
}


/* --------------------- 用户的类 ----------------------- */
class User{
  String username;
  //这里可能还有更多与用户相关的个人信息，例如性别等

  List<Plan> userPlans;//该用户的计划
  List<Plan> userPointPlans;//该用户的时间点类计划
  List<Plan> userIntervalPlans;//该用户的时间段类计划
  List<Group> userGroups;//该用户的群组

  //constructor
  User(String username){
    this.username = username;
    this.userPlans = [];
    this.userGroups = [];
    this.userPointPlans = [];
    this.userIntervalPlans = [];
  }

  //添加用户自己的计划
  void addPlan(Plan plan){
    if(plan != null && !this.userPlans.contains(plan)){
      plan.username = this.username;
      this.userPlans.add(plan);
      if(plan.plantype == 'point') this.userPointPlans.add(plan);
      else if(plan.plantype == 'interval') this.userIntervalPlans.add(plan);
    }
  }

  //添加用户自己的群组
  void addGroup(Group group){
    if(group != null && !this.userGroups.contains(group)){
      this.userGroups.add(group);
    }
  }

}   

/* ------------------- 公共时间的结果 ----------------------*/
class Result{
  String date;
  String beginTime, endTime;//time
  List<String> conflicts = [];
  get deltaTime => Datee.deltaTime(beginTime, endTime);
  get flag => (this.deltaTime >= CalendarComponent.limitDelta)?true:false;

  Result(String begin, String end){
    this.beginTime = begin;
    this.endTime = end;
  }

  //传入一个时间点时间， 根据是否冲突来进行下一步计算
  void dealConflict(Plan plan){

  }


}



/* ------------- 辅助计算日期与时间用的类 为了防止命名冲突，取名Datee -----------*/
class Datee{
  /* ------------ 关于日期计算处理的一些静态方法 -----------------*/
  //比较两个日期
  static int dateCompare(String a, String b){
    //2019-01-07
    if(Datee.dateYear(a) > Datee.dateYear(b)) return 1;
    else if(Datee.dateYear(a) < Datee.dateYear(b)) return -1;
    else{
      //同一年的情况，先比月
      if(Datee.dateMonth(a) > Datee.dateMonth(b)) return 1;
      else if(Datee.dateMonth(a) < Datee.dateMonth(b)) return -1;
      else{
        if(Datee.dateDay(a) == Datee.dateDay(b)) return 0;
        else return (Datee.dateDay(a) > Datee.dateDay(b))?1:-1; 
      }
    }
  }//end dateCompare()

  //从2019-01-07中获取年月日
  static int dateYear(String date){
    return int.parse(date.substring(0,4));
  }
  static int dateMonth(String date){
    return int.parse(date.substring(5,7));
  }
  static int dateDay(String date){
    return int.parse(date.substring(8));
  }

  //比较两个时间08:30
  static int timeCompare(String a, String b){
    if(Datee.timeHour(a) > Datee.timeHour(b)) return 1;
    else if(Datee.timeHour(a) < Datee.timeHour(b)) return -1;
    else{
      //如果小时一样
      if(Datee.timeMinute(a) > Datee.timeMinute(b)) return 1;
      else if(Datee.timeMinute(a) < Datee.timeMinute(b)) return -1;
      else return 0;
    }
  }

  //从08:30中获取小时与分钟
  static int timeHour(String time){
    return int.parse(time.substring(0,2));
  }
  static int timeMinute(String time){
    return int.parse(time.substring(3));
  }

  //计算两个时间的差值 - 分钟
  static int deltaTime(String begin, String end){
    return (Datee.timeHour(end) * 60 + Datee.timeMinute(end))
          - (Datee.timeHour(begin) * 60 + Datee.timeMinute(begin));
  }

  

}