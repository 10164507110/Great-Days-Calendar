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
  List<int> days = new List<int>.filled(42, -1);
  List<String> day_color = new List<String>.filled(42, "lightgrey");
  List<int> month_day = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  List<bool> hasEvent = new List<bool>.filled(42, false);
  int now_day, now_month, now_year;
  bool groupsFlag = true;//默认我的群组展开
  bool plansFlag = true;//默认我的计划展开
  bool optionsFlag = true;//默认我的群组中选项展开
  bool addGroupFlag = true;//默认加入群组选项展开
  
  /*----- 我的计划有关的变量 -------*/
  bool submit = false;
  String planname = '';//计划名称
  String plantype = '';//时间点/时间段

  String plandatePoint = '';//日期信息
  String plantimePoint = '';//具体的时间
  String plandateBegin = '';//日期信息(时间段起点)
  String plantimeBegin = '';//具体的时间
  String plandateEnd = '';//日期信息(时间段终点)
  String plantimeEnd = '';//具体的时间

  final String content = 'click me';


      /* ----- 伪数据库 ----- */
          List<String> groups = ["猪组", "英汉互译分队", "2016级教信班委通知群"];
          List<String> plans = ["看jojob", "搭dart环境"];

      /* ------------------- */


  //constructor
  CalendarComponent(){
    //初始化将日历设置成当日
    DateTime now = new DateTime.now();
    now_day = now.day;
    now_month = now.month;
    now_year = now.year;
    calendarUpdate();
  }

  /*---------------------------methods---------------------------*/
  /*---------- 日历本体相关 ----------*/
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

  }//close calendarUpdate()

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


  /* ------ 与我的计划相关的函数 ---------*/
  // 我的计划的表单提交
  void submitPlan(){
    submit = true;
  }
  
}