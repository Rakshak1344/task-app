import 'package:app/features/profile/views/profile_page.dart';
import 'package:app/navigation/app_route_name.dart';
import 'package:app/utils/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../../config/task_test_app_config.dart';
import '../robots/profile_robot.dart';

void main() {
  patrolTest("Signed in user sees their details on the profile page", (
    $,
  ) async {
    // Arrange
    var app = TaskTestApp();
    var user = await app.setupLoggedIn();
    await app.init($);

    var profileRobot = ProfileRobot(app);

    // Act
    await profileRobot.openProfile();

    // Assert
    expect($(ProfilePage), findsOneWidget);
    expect($(user.name!), findsOneWidget);
    expect($('Logged in as ${user.email}'), findsOneWidget);
  });

  patrolTest("Profile is reachable from the task list", ($) async {
    // Arrange
    var app = TaskTestApp();
    await app.setupLoggedIn();
    await app.init($);

    var profileRobot = ProfileRobot(app);

    expect(app.getCurrentRoute(), app.getRouteFor(AppRouteName.tasks.list));
    expect($(K.profile.openButton), findsOneWidget);

    // Act
    await profileRobot.openProfile();

    // Assert
    expect(
      app.getCurrentRoute(),
      app.getRouteFor(AppRouteName.profile.profile),
    );
    expect($(ProfilePage), findsOneWidget);
  });

  patrolTest("Logging out clears the session and returns to the login page", (
    $,
  ) async {
    // Arrange
    var app = TaskTestApp();
    await app.setupLoggedIn();
    await app.init($);

    var profileRobot = ProfileRobot(app);
    await profileRobot.openProfile();

    expect(app.getAccessToken(), isNotNull);
    expect(app.getLoggedInUser(), isNotNull);

    // Act
    await profileRobot.logout();

    // Assert
    expect(app.getAccessToken(), isNull);
    expect(app.getLoggedInUser(), isNull);
    expect(app.getCurrentRoute(), app.getRouteFor(AppRouteName.auth.login));
    expect($(K.auth.loginButton), findsOneWidget);
  });
}
