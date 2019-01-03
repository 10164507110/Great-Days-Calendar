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
    client.post(
        "http://localhost:8002/register",
        body:{"name": "admin","password": "abc123"})
        .then((response) => print(response.body))
        .whenComplete(client.close);
  }

  
}