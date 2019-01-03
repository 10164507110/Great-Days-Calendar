import 'package:angular/angular.dart';

import 'src/calendar/calendar_component.dart';
import 'src/Register/register_component.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [CalendarComponent,RegisterComponent],
)
class AppComponent {
  // Nothing here yet. All logic is in TodoListComponent.
}
