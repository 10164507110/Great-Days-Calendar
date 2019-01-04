import 'package:calendar/mailer/mailer.dart';
import 'package:calendar/smtp_server/ecnustumail.dart';
import 'package:calendar/user.dart';

import 'my_server.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class MyServerChannel extends ApplicationChannel {
  /// Initialize services in this method.
  ManagedContext context;
  AuthServer authServer;
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
//    CORSPolicy.defaultPolicy.allowedOrigins = ["http://localhost:8080/"];
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    // Prefer to use `link` instead of `linkFunction`.
    // See: https://aqueduct.io/docs/http/request_controller/
    router
        .route("/login").link(()=>LoginController());
    router
        .route("/register").link(()=>RegisterController());
    router
        .route("/sendemail").link(()=>SendEmailController());

    return router;
  }
}


class LoginController extends ResourceController{

  @Operation.post()
  Future<Response> login(@Bind.body() User testuser) async {
    if(testuser.username == '' || testuser.password == '') {
      return Response.badRequest(body: {"error": "username and password required."});
    }
    var selectUserPassword = await User.selectPassword(testuser.username);
    if(selectUserPassword != "wrong" && selectUserPassword == testuser.password){
      return Response.ok({"success":"register success"});
    }else return Response.badRequest(body: {"error": "wrong username or password."});
  }
}

class RegisterController extends ResourceController{

  @Operation.post()
  Future<Response> register(@Bind.body() User testuser) async {
    bool ifregister = await User.createUser(testuser);
    if(ifregister == true){
      return Response.ok({"success":"register success"});
    }else return Response.badRequest(body: {"error": "register failed"});
  }

}

class SendEmailController extends ResourceController{

  @Operation.post()
  Future<Response> register(@Bind.body() User testuser) async {
    String identify_Code = testuser.identify_code;
    String mailbox = testuser.mailbox;
    String stmpusername = "10164507121@stu.ecnu.edu.cn";
    String stmpassword = "Qxy071561";
    print(mailbox);
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
      ..html = "<h1>Hey! Here's your identity code:</h1>"+identify_Code;

    final sendReports = await send(message, smtpServer);
//    sendReports.forEach((sr) {
//      if (sr.sent) {
//        print('Message sent');
//        print('ok');
//        return Response.ok({"success":"send success"});
//      }
//      else {
//        print('Message not sent.');
//        for (var p in sr.validationProblems) {
//          print('Problem: ${p.code}: ${p.msg}');
//          return Response.badRequest(body: {"error": "send failed"});
//        }
//      }
//    });

  }

}


