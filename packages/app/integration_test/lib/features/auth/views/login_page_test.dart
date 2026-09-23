import 'package:app/features/auth/views/login_page.dart';
import 'package:app/features/auth/views/states/login_state.dart';
import 'package:app/features/tasks/views/task_list_page.dart';
import 'package:app/navigation/app_route_name.dart';
import 'package:app/utils/keys.dart';
import 'package:core/error/exceptions/laravel_validation_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../../config/task_test_app_config.dart';
import '../consts/k_auth.dart';
import '../repositories/fake_auth_network_repository.dart';
import '../robots/auth_robot.dart';

void main() {
  patrolTest(
    "User can log in with valid credentials and land on the task list",
    ($) async {
      // Arrange
      var app = TaskTestApp();
      var existingUser = await app.setupWithExistingUser();
      await app.init($);

      var authRobot = AuthRobot(app);
      var taskListRoute = app.getRouteFor(AppRouteName.tasks.list);

      expect($(K.auth.loginButton), findsOneWidget);
      expect(app.getCurrentRoute(), isNot(taskListRoute));
      expect(app.getAccessToken(), isNull);

      // Act
      await authRobot.login(KAuth.email, KAuth.password);

      // Assert
      expect(app.getCurrentRoute(), taskListRoute);
      expect($(TaskListPage), findsOneWidget);
      expect(app.getAccessToken(), isNotNull);
      expect(app.getLoggedInUser(), existingUser);
    },
  );

  patrolTest("Wrong password keeps the user on the login page", ($) async {
    // Arrange
    var app = TaskTestApp();
    await app.setupWithExistingUser();
    await app.init($);

    var authRobot = AuthRobot(app);
    var loginRoute = app.getRouteFor(AppRouteName.auth.login);

    expect(app.getCurrentRoute(), loginRoute);

    // Act
    await authRobot.login(KAuth.email, KAuth.invalidPassword);

    // Assert
    expect(app.getCurrentRoute(), loginRoute);
    expect($(LoginPage), findsOneWidget);
    expect(app.getAccessToken(), isNull);
    expect(app.getLoggedInUser(), isNull);

    var loginState = app.container.read(loginStateProvider);

    expect(loginState.hasError, isTrue);
    expect(loginState.error, isA<LaravelValidationException>());
    expect(
      (loginState.error! as LaravelValidationException).errors['email'],
      contains(FakeAuthNetworkRepository.invalidCredentialsMessage),
    );
  });
}
