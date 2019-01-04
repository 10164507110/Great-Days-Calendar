import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:sqljocky5/sqljocky.dart';
import 'package:calendar/mailer/mailer.dart';
import 'package:calendar/smtp_server/ecnustumail.dart';
import 'channel.dart';
class User extends Serializable {

  int id;
  String username;
  String password;
  String mailbox;
  String identify_code;

  static Future<List> getAll()async {
    List results;
    var s = ConnectionSettings(
      user: "deit2016",
      password: "deit2016@ecnu",
      host: "www.muedu.org",
      port: 3306,
      db: "deit2016db_10164507121",
    );

    // create a connection
    print("Opening connection ...");
    var conn = await MySqlConnection.connect(s);
    print("Opened connection!");

//        await readData(conn);
    Results result = await (await conn
        .execute('SELECT *'
        'FROM user'))
        .deStream();
    print(result);
    print(result.map((r) => r.byName('username')));
    results = result.toList();
    return results;
  }

  static Future<String> selectPassword(String username)async {
    var stuList;
    String password;
    stuList = await getAll();
    print(username);
    for(int i=0;i<stuList.length;i++){
      if(stuList[i][1]==username)
        password = stuList[i][3];
    }
    if(password!=null){
      return password;
    }else{
      password = "wrong";
      return password;
    }

  }

  static sendEmail(String code, String mailbox) async {

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
      ..html = "<h1>Hey! Here's your identity code:</h1>"+code;

    final sendReports = await send(message, smtpServer);
    sendReports.forEach((sr) {
      if (sr.sent) {
        print('Message sent');
        ifsend = "y";

        print(ifsend);
        return ifsend;
//        return Response.ok({"success":"send success"});
      }
      else {
        print('Message not sent.');
        for (var p in sr.validationProblems) {
          print('Problem: ${p.code}: ${p.msg}');
//          return ifsend;
//          return Response.badRequest(body: {"error": "send failed"});
        }
      }
    });
  }

  @override
  void readFromMap(Map<String, dynamic> map) {
//    id = map['id'];
    username = map['username'];
    password = map['password'];
    mailbox = map['mailbox'];
    identify_code = map['identify_code'];
  }

  @override
  Map<String, dynamic> asMap() {
    return {
//      'id': id,
      'username': username,
      'password':password,
      'mailbox':mailbox,
      'identify_code':identify_code
    };
  }

  static createUser(User testuser) async {
//    List results;
    bool ifRegister = false;
    String username = testuser.username;
    String password = testuser.password;
    String mailbox = testuser.mailbox;
    print(username);
    var s = ConnectionSettings(
      user: "deit2016",
      password: "deit2016@ecnu",
      host: "www.muedu.org",
      port: 3306,
      db: "deit2016db_10164507121",
    );

    // create a connection
    print("Opening connection ...");
    var conn = await MySqlConnection.connect(s);
    print("Opened connection!");

    print("Inserting rows ...");
    await conn.preparedWithAll("INSERT INTO user (username,password,email) VALUES (?,?,?)", [
      [username, password, mailbox],
      ]);
    ifRegister = true;
    return ifRegister;
  }
}