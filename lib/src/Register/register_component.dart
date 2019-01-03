import 'dart:convert';
import 'dart:html';
import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:calendar/src/calendar/calendar_component.dart';
import 'package:calendar/src/route_paths.dart';
import 'package:http/http.dart' as http;
import 'package:calendar/src/routes.dart';

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
    CalendarComponent,
    routerDirectives,
    coreDirectives
  ],
  pipes: [commonPipes],
)

class RegisterComponent{

  String username = '';
  String password = '';
  Router _router;
//  _router.;
  bool ifRegister = false;
  RegisterComponent(this._router);

  register(){
    var client = new http.Client();
    var url = "http://localhost:8002/register";
    var body = json.encode({"name": username,"password": password});
    var headers = {
      "content-type":"application/json"
    };
      Future<NavigationResult> gotoDetail() =>
      _router.navigate(RoutePaths.calendar.toUrl());
    client.post(
        url,
        headers: headers,
        body:body)
        .then((response) {
//          print(response.statusCode);
          if(response.statusCode == 200) {
//            ifRegister = true;
//            client.get(RoutePaths.calendar.toUrl());
            print(RoutePaths.calendar.toUrl().toString());
//            print(_router);
//            _router.navigate(RoutePaths.calendar.toUrl());
            gotoDetail();
          }
          else
            window.alert("请输入正确的用户名和密码");
//          print(response.body);
        })
        .whenComplete(client.close);
  }

  
}