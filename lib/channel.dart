
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
        .route("/register").link(()=>RegisterController());
    return router;
  }
}


class RegisterController extends ResourceController{

  @Operation.post()
  Future<Response> register(@Bind.body() User testuser) async {
    if(testuser.username == '' || testuser.password == '') {
      return Response.badRequest(body: {"error": "username and password required."});
    }
    var selectUserPassword = await User.selectPassword(testuser.username);
    if(selectUserPassword != "wrong" && selectUserPassword == testuser.password){
      return Response.ok({"success":"register success"});
    }else return Response.badRequest(body: {"error": "wrong username or password."});
  }
}

