import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'dart:html';


@Component(
  selector: 'calendar',
  styleUrls: ['calendar_component.css'],
  templateUrl: 'calendar_component.html',
  directives: [
    materialInputDirectives,
    MaterialRadioComponent,
    MaterialRadioGroupComponent,
    NgFor,
    NgIf,
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
  int now_day, now_month, now_year;

  /*----- 我的群组有关的变量 -------*/
  bool groupsFlag = true;//默认我的群组展开
  bool optionsFlag = true;//默认我的群组中选项展开
  bool addGroupFlag = true;//默认加入群组选项展开
  
  /*----- 我的计划有关的变量 -------*/
  List<String> plancolor = [];
  List<String> dotOrDash = [];
  List<String> hovercolor = new List<String>.filled(42, "hovercolor-");
  final int COLORNUM = 18;//颜色数目
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

      /* ----- 伪数据库 ----- */
          List<String> groups = ["猪组", "英汉互译分队", "2016级教信班委通知群"];
          List<String> plans = ["看jojob", "搭dart环境"];
          List<plan> myplans = [];

      /* ------------------- */


  //constructor
  CalendarComponent(){
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

  }//close calendarUpdate()

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
              if(myplans[j].plantype=='point' && myplans[j].plandatePoint == date)
                plancolor[j] = planColor(i);
            }//end for
          }//end if(!=plancolor-)
          eventColor[getDayIndex(day)] = planColor(i);
        }
      }//end if
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

  //点击添加事件(伪)
  void addEvent(int i){
    hasEvent[i] = true;
    // Element plans = querySelector("#plans");
    // Element li = new Element.li();
    // li.innerHtml = "Hello World";
    // plans.append(li);
  }
  
  //点击refresh按钮，重置日历
  void refresh(){
    DateTime now = new DateTime.now();
    now_day = now.day;
    now_month = now.month;
    now_year = now.year;
    calendarUpdate();
  }

  //返回这一天在这个日历上的index
  int getDayIndex(int day){
    DateTime firstday = new DateTime.utc(now_year, now_month, 1);
    int first_weekday = firstday.weekday;

    int now_pos = first_weekday % 7;
    return now_pos + day - 1;
  }
















 /* ----------------------- 与我的群组相关的函数 -------------------------------*/  
 //点击下拉菜单的开头按钮，收回/展开下拉一级菜单
  void dropDownOptions(String option){
    switch(option){
      case 'groupOption':{        
        this.optionsFlag = !this.optionsFlag;
        if(!optionsFlag)groupsFlag = optionsFlag;
        break;
      }
    }  
  }

  //点击下拉菜单的开头按钮，收回/展开下拉二级菜单
  void dropDownList(String target){
    switch(target){
      case 'group':this.groupsFlag = !this.groupsFlag;break;
      case 'plan':this.plansFlag = !this.plansFlag;break;
      case 'addgroup':this.addGroupFlag = !this.addGroupFlag;
    }
  } 















  /* -------------------------- 与我的计划相关的函数 ------------------------------*/
  //填充我的计划(应该从数据库读入)
  void fillMyplans(){
    myplans.add(new plan("看JOJO", "point", "2019-01-07", "18:30"));
    myplans.add(new plan("搭Dart环境", "point", "2019-01-10", "21:30"));
    myplans.add(new plan("期末周，苟延残喘", "interval", "2019-01-01", "00:00", "2019-01-17","00:00"));

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

  void clearPlans(){
    //清空相关变量
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
      plan newplan = null;
      if(this.plantype == 'point'){
        newplan = new plan(planname, "point", plandatePoint, plantimePoint);
      }else if(this.plantype == 'interval'){
        newplan = new plan(planname, "interval", plandateBegin, plantimeBegin, plandateEnd, plantimeEnd);
      }
      myplans.add(newplan);
      fillPlanColor();//更新颜色
      fillPlanType();//更新点划
      calendarUpdate();//更新日历
    }
      


    //之后，清空相关变量
    clearPlans();
  }
  
}

















class plan{
  String planname;
  String plantype;
  String plantimePoint, plandatePoint;
  String plantimeBegin, plantimeEnd;
  String plandateBegin, plandateEnd;

  //constructor
  plan(String planname, String plantype, String date1, String time1, [String date2, String time2]){
    this.planname = planname;
    this.plantype = plantype;
    if(plantype == 'point'){
      this.plandatePoint = date1; this.plantimePoint = time1;
    }else if(plantype == 'interval'){
      this.plandateBegin = date1; this.plantimeBegin = time1;
      this.plandateEnd = date2; this.plantimeEnd = time2;
    }
  }

}