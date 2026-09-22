import 'package:app/features/auth/views/signup_page.dart';
import 'package:app/features/auth/views/states/signup_state.dart';
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
    "New user can create an account and land on the task list",
    ($) async {
      // Arrange
      var app = TaskTestApp();
      await app.init($);

      var authRobot = AuthRobot(app);
      var taskListRoute = app.getRouteFor(AppRouteName.tasks.list);

      expect($(K.auth.createAccountButton), findsOneWidget);
      expect(app.getAccessToken(), isNull);

      await authRobot.goToSignup();
      expect($(SignupPage), findsOneWidget);
      expect(app.getCurrentRoute(), app.getRouteFor(AppRouteName.auth.signup));

      // Act
      await authRobot.signup(KAuth.name, KAuth.email, KAuth.password);

      // Assert
      expect(app.getCurrentRoute(), taskListRoute);
      expect($(TaskListPage), findsOneWidget);
      expect(app.getAccessToken(), isNotNull);
      expect(app.getLoggedInUser()?.email, KAuth.email);
    },
  );

  patrolTest("Signing up with an already registered email fails", ($) async {
    // Arrange
    var app = TaskTestApp();
    var existingUser = await app.setupWithExistingUser();
    await app.init($);

    var authRobot = AuthRobot(app);
    var signupRoute = app.getRouteFor(AppRouteName.auth.signup);

    await authRobot.goToSignup();

    expect($(SignupPage), findsOneWidget);
    expect(app.getCurrentRoute(), signupRoute);

    // Act
    await authRobot.signup(KAuth.name, existingUser.email, KAuth.password);

    // Assert
    expect(app.getCurrentRoute(), signupRoute);
    expect($(SignupPage), findsOneWidget);
    expect(app.getAccessToken(), isNull);
    expect(app.getLoggedInUser(), isNull);

    var signupState = app.container.read(signupStateProvider);

    expect(signupState.hasError, isTrue);
    expect(signupState.error, isA<LaravelValidationException>());
    expect(
      (signupState.error! as LaravelValidationException).errors['email'],
      contains(FakeAuthNetworkRepository.emailTakenMessage),
    );
  });
}
