import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:sqljocky5/sqljocky.dart';

class User extends Serializable {

  int id;
  String username;
  String password;

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
    username = map['name'];
    password = map['password'];
  }

  @override
  Map<String, dynamic> asMap() {
    return {
//      'id': id,
      'name': username,
      'password':password
    };
  }
}