import 'package:angular_router/angular_router.dart';

const idParam = 'id';

class RoutePaths {
  static final calendar = RoutePath(path: 'calendar');
  static final login = RoutePath(path: 'login');
  static final register = RoutePath(path: 'register');
  static final calendar_test = RoutePath(path: '${calendar.path}/:$idParam');
}

int getId(Map<String, String> parameters) {
  final id = parameters[idParam];
  return id == null ? null : int.tryParse(id);
}