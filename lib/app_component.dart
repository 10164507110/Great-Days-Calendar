import 'package:angular/angular.dart';
import 'dart:async';
import 'package:angular_router/angular_router.dart';
import 'package:calendar/src/route_paths.dart';
import 'package:calendar/src/routes.dart';

import 'src/calendar/calendar_component.dart';
import 'src/Register/register_component.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [CalendarComponent,RegisterComponent,routerDirectives],
  exports: [RoutePaths, Routes]
)
class AppComponent {
  // Nothing here yet. All logic is in TodoListComponent.
//  Router _router;
//  AppComponent(this._router);
//  Future<NavigationResult> gotoDetail() =>
//      _router.navigate(RoutePaths.calendar.toUrl());

}
