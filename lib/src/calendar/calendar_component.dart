import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'dart:html';

@Component(
  selector: 'calendar',
  styleUrls: ['calendar_component.css'],
  templateUrl: 'calendar_component.html',
  directives: [
    NgFor,
    NgIf,
  ],
)

class CalendarComponent{
  List<int> days = new List<int>.filled(42, -1);
  List<String> day_color = new List<String>.filled(42, "lightgrey");
  List<int> month_day = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  int now_month, now_year;
  CalendarComponent(){
    DateTime now = new DateTime.now();
    now_month = now.month;
    now_year = now.year;
    DateTime firstday = new DateTime.utc(now_year, now_month, 1);
    int first_weekday = firstday.weekday;

    int now_pos = first_weekday % 7;
    days[now_pos] = 1;
    day_color[now_pos] = "black";
    leapYear(now_year);

    //填上这个月的日期，并设为黑色
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

  }

  void leapYear(int year){
    month_day[2] = 
      (year%4==0 &&year%100!=0 || year%400==0) ? 29:28;
  }

}