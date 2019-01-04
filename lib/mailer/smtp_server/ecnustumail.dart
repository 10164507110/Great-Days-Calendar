import '../smtp_server.dart';

SmtpServer ecnustumail(String username, String password) =>
    new SmtpServer('smtp.exmail.qq.com', username: username, password: password);