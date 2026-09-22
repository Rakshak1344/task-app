import 'package:app/utils/keys.dart';
import 'package:core/test/page_robot.dart';

class ProfileRobot extends PageRobot {
  ProfileRobot(super.app);

  Future<void> openProfile() async {
    await $.tap($(K.profile.openButton));
    await $.pumpAndSettle();
  }

  Future<void> logout() async {
    await $.tap($(K.profile.logoutButton));
    await app.dismissSnackBar();
    await $.pumpAndSettle();
  }
}
