import 'package:angular_router/angular_router.dart';
import 'route_paths.dart';

export 'route_paths.dart';
import 'calendar/calendar_component.template.dart' as calendar_component;
import 'Register/register_component.template.dart' as register_component;

class Routes {
  static final calendar = RouteDefinition(
    routePath: RoutePaths.calendar,
    component: calendar_component.CalendarComponentNgFactory,
  );

  static final register = RouteDefinition(
    routePath: RoutePaths.register,
    component: register_component.RegisterComponentNgFactory,
    useAsDefault: true,
  );

  static final all = <RouteDefinition>[
    register,
    calendar
  ];
}
