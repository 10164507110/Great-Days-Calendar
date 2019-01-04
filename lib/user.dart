import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:sqljocky5/sqljocky.dart';

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

  static Future<String> selectPassword(username)async {
    var stuList;
    var password;
    stuList = await getAll();
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