import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:http/http.dart' as http;


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
  ],
)

class RegisterComponent{

  String username = '';
  String password = '';

  register(){
    var client = new http.Client();
    var url = "http://localhost:8002/register";
    var body = json.encode({"name": "admin","password": "abc123"});
    Map headers = {
      'content-type':'application/json'
    };
//    final response = http.post(url,body: body,headers: headers);
    client.post(
        url,
        headers: headers,
        body:body)
        .then((response) => print(response.body))
        .whenComplete(client.close);
//    print(response);
  }

  
}