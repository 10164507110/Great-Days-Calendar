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
  String mailbox = '';
  Router _router;
//  _router.;
  RegisterComponent(this._router);
  register(){
    var client = new http.Client();
    var url = "http://localhost:8002/register";
    var body = json.encode({"username": username,"mailbox":mailbox,"password": password});
    var headers = {
      "content-type":"application/json"
    };

    Future<NavigationResult> gotoLogin() =>
        _router.navigate(RoutePaths.login.toUrl());

    client.post(
        url,
        headers: headers,
        body:body)
        .then((response) {
          if(response.statusCode == 200) {
            window.alert("注册成功");
            gotoLogin();
          }
          else
            window.alert("注册失败");
//          print(response.body);
        })
        .whenComplete(client.close);
  }

  
}