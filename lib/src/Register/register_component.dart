import 'dart:convert';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:calendar/src/calendar/calendar_component.dart';
import 'package:http/http.dart' as http;


@Component(
  selector: 'register',
  styleUrls: ['register_component.css'],
  templateUrl: 'register_component.html',
  directives: [
    materialInputDirectives,
    MaterialRadioComponent,
    MaterialRadioGroupComponent,
    NgFor,
    NgIf,
    CalendarComponent
  ],
)

class RegisterComponent{

  String username = '';
  String password = '';
  bool ifRegister = false;
  register(){
    var client = new http.Client();
    var url = "http://localhost:8002/register";
    var body = json.encode({"name": username,"password": password});
    var headers = {
      "content-type":"application/json"
    };
    client.post(
        url,
        headers: headers,
        body:body)
        .then((response) {
//          print(response.statusCode);
          if(response.statusCode == 200)
            ifRegister = true;
          else
            window.alert("请输入正确的用户名和密码");
//          print(response.body);
        })
        .whenComplete(client.close);
  }



  
}