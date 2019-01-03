import 'dart:convert';

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
//    final response = http.post(url,body: body,headers: headers);
    client.post(
        url,
        headers: headers,
        body:body)
        .then((response) => ifRegister = true)
        .whenComplete(client.close);
//    print(response);
  }

  
}