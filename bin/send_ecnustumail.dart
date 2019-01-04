import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:calendar/mailer/mailer.dart';
import 'package:calendar/smtp_server/ecnustumail.dart';

/// Test mailer by sending email
main(List<String> rawArgs) async {
  String username = "10164507121@stu.ecnu.edu.cn";
  List<String> tos = ["707132127@qq.com"]; //收件人

  //if tos is Empty, send myself
  if (tos.isEmpty)
    tos.add(username.contains('@') ? username : username);

  final smtpServer = ecnustumail(username, "Qxy071561");
  Iterable<Address> toAd(Iterable<String> addresses) =>
      (addresses ?? <String>[]).map((a) => new Address(a));

  final message = new Message()
    ..from = new Address('10164507121@stu.ecnu.edu.cn')
    ..recipients.addAll(toAd(tos))
    ..subject = 'Test Dart Mailer library :: 😀 :: ${new DateTime.now()}'
    ..text = 'This is the plain text.\nThis is line 2 of the text part.'
    ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";

//附件    ..attachments.addAll(toAt(args[attachArgs] as Iterable<String>));

  final sendReports = await send(message, smtpServer);
  sendReports.forEach((sr) {
    if (sr.sent)
      print('Message sent');
    else {
      print('Message not sent.');
      for (var p in sr.validationProblems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  });
}