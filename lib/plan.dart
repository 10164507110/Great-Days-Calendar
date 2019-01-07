import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:sqljocky5/sqljocky.dart';
import 'package:calendar/mailer/mailer.dart';
import 'package:calendar/smtp_server/ecnustumail.dart';
import 'channel.dart';
class Plan extends Serializable {

  String mailbox;
  String deadline;


  static Future<String> sendEmail(String mailbox, String deadline) async {

    String stmpusername = "10164507121@stu.ecnu.edu.cn";
    String stmpassword = "Qxy071561";
    print(mailbox);
    String ifsend = "n";
    List<String> tos = [mailbox]; //收件人

    //if tos is Empty, send myself
    if (tos.isEmpty)
      tos.add(stmpusername);

    final smtpServer = ecnustumail(stmpusername, stmpassword);
    Iterable<Address> toAd(Iterable<String> addresses) =>
        (addresses ?? <String>[]).map((a) => new Address(a));

    final message = new Message()
      ..from = new Address('10164507121@stu.ecnu.edu.cn')
      ..recipients.addAll(toAd(tos))
      ..subject = 'Test Dart Mailer library :: 😀 :: ${new DateTime.now()}'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html = "<h1>deadline after</h1>"+deadline.toString()+"<h1>Days</h1>";

    final sendReports = await send(message, smtpServer);
    sendReports.forEach((sr) {
      if (sr.sent) {
        print('Message sent');
        ifsend = "y";
      }
      else {
        print('Message not sent.');
        for (var p in sr.validationProblems) {
          print('Problem: ${p.code}: ${p.msg}');
        }
      }
    });
    return ifsend;
  }

  @override
  void readFromMap(Map<String, dynamic> map) {
    deadline = map['deadline'];
    mailbox = map['mailbox'];
  }

  @override
  Map<String, dynamic> asMap() {
    return {
      'deadline':deadline,
      'mailbox':mailbox,
    };
  }

}