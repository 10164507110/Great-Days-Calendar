import 'dart:convert';
import 'dart:html';
import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/model/menu/menu.dart';
import 'package:angular_router/angular_router.dart';
import 'package:calendar/src/calendar/calendar_component.dart';
import 'package:calendar/src/route_paths.dart';
import 'package:http/http.dart' as http;
import 'package:calendar/src/routes.dart';

@Component(
  selector: 'login',
  styleUrls: ['login_component.css'],
  templateUrl: 'login_component.html',
  directives: [
    materialInputDirectives,
    MaterialRadioComponent,
    MaterialRadioGroupComponent,
    NgFor,
    NgIf,
    CalendarComponent,
    routerDirectives,
    coreDirectives,
    DropdownMenuComponent,
    MaterialIconComponent,
    MaterialMenuComponent,
    MaterialFabMenuComponent
  ],
  pipes: [commonPipes],
  providers: [popupBindings]
)


class LoginComponent{

  String username = '';
  String password = '';
  Router _router;
  LoginComponent(this._router);
//  final MenuItem menuItem = MenuItem('your label',
//      icon: Icon('add'),
//      subMenu: MenuModel([
//        MenuItemGroup([
//          MenuItem('item1-1', tooltip: 'your tooltip'),
//          MenuItem('item1-2', tooltip: 'your second tooltip')
//        ], 'group1'),
//        MenuItemGroup([MenuItem('item2-1'), MenuItem('item2-2')], 'group2'),
//      ]));


  Future<NavigationResult> gotoRegister() =>
      _router.navigate(RoutePaths.register.toUrl());

  login(){
    var client = new http.Client();
    var url = "http://localhost:8002/login";
    var body = json.encode({"username": username,"password": password});
    var headers = {
      "content-type":"application/json"
    };

    print(username);

    Future<NavigationResult> gotoCalendar() =>
      _router.navigate(RoutePaths.calendar.toUrl());

    client.post(
        url,
        headers: headers,
        body:body)
        .then((response) {
          if(response.statusCode == 200) {
            print(RoutePaths.calendar.toUrl().toString());
            gotoCalendar();
          }
          else
            window.alert("请输入正确的用户名和密码");
//          print(response.body);
        })
        .whenComplete(client.close);
  }

}
