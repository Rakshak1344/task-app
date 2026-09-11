import 'package:app/features/auth/navigation/auth_route_names.dart';
import 'package:app/features/profile/navigation/profile_route_names.dart';
import 'package:app/features/tasks/navigation/task_route_names.dart';

class AppRouteName {
  /// Unauthenticated routes
  static const String root = 'root';
  static const AuthRouteNames auth = AuthRouteNames();

  /// authenticated routes
  static const TaskRouteNames tasks = TaskRouteNames();
  static const ProfileRouteNames profile = ProfileRouteNames();

  static const String dev = "dev";
}
