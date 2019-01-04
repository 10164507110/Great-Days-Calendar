import 'dart:convert';
import 'dart:html';
import 'dart:async';
import 'dart:math';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:calendar/src/calendar/calendar_component.dart';
import 'package:calendar/src/route_paths.dart';
import 'package:http/http.dart' as http;
import 'package:calendar/src/routes.dart';
import 'package:calendar/mailer/mailer.dart';
import 'package:calendar/smtp_server/ecnustumail.dart';

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
  String identify_code ='';
  String code = '';
  Router _router;
//  _router.;
  RegisterComponent(this._router);

  sendEmail()async {
    var random = Random();
    identify_code = (random.nextInt(8999)+1000).toString();
    var client = new http.Client();
    var url = "http://localhost:8002/sendemail";
    var body = json.encode(
        {"mailbox": mailbox, "identify_code": identify_code});
    var headers = {
      "content-type": "application/json"
    };

    client.post(
        url,
        headers: headers,
        body: body)
        .then((response) {
      if (response.statusCode == 200) {
        window.alert("验证码已发送");
      }
      else
        window.alert("验证码发送失败");
//          print(response.body);
    })
        .whenComplete(client.close);
//    String stmpusername = "10164507121@stu.ecnu.edu.cn";
//    String stmpassword = "Qxy071561";
//    print(mailbox);
//    List<String> tos = [mailbox]; //收件人
//
//    //if tos is Empty, send myself
//    if (tos.isEmpty)
//      tos.add(stmpusername);
//
//    final smtpServer = ecnustumail(stmpusername, stmpassword);
//    Iterable<Address> toAd(Iterable<String> addresses) =>
//        (addresses ?? <String>[]).map((a) => new Address(a));
//
//    final message = new Message()
//      ..from = new Address('10164507121@stu.ecnu.edu.cn')
//      ..recipients.addAll(toAd(tos))
//      ..subject = 'Test Dart Mailer library :: 😀 :: ${new DateTime.now()}'
//      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
//      ..html = "<h1>Hey! Here's your identity code:</h1>";
//
//    final sendReports = await send(message, smtpServer);
//    sendReports.forEach((sr) {
//      if (sr.sent) {
//        window.alert("已发送，注意查收");
//        print('Message sent');
//      }
//      else {
//        print('Message not sent.');
//        for (var p in sr.validationProblems) {
//          print('Problem: ${p.code}: ${p.msg}');
//        }
//      }
//    });
  }

  register() {
    if (identify_code != code) {
      window.alert("验证码输入错误，请重新输入");
    }
    else {
      var client = new http.Client();
      var url = "http://localhost:8002/register";
      var body = json.encode(
          {"username": username, "mailbox": mailbox, "password": password});
      var headers = {
        "content-type": "application/json"
      };

      Future<NavigationResult> gotoLogin() =>
          _router.navigate(RoutePaths.login.toUrl());

      client.post(
          url,
          headers: headers,
          body: body)
          .then((response) {
        if (response.statusCode == 200) {
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
  
}