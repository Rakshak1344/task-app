import 'package:app/utils/keys.dart';
import 'package:core/test/page_robot.dart';

class AuthRobot extends PageRobot {
  AuthRobot(super.app);

  Future<void> login(String email, String password) async {
    await enterEmail(email);
    await enterPassword(password);
    await submitLogin();
  }

  Future<void> signup(String name, String email, String password) async {
    await enterName(name);
    await enterEmail(email);
    await enterPassword(password);
    await enterConfirmPassword(password);
    await submitSignup();
  }

  Future<void> goToSignup() async {
    await $.tap($(K.auth.createAccountButton));
    await $.pumpAndSettle();
  }

  Future<void> enterName(String name) async {
    await $.enterText($(K.auth.nameEntry), name);
  }

  Future<void> enterEmail(String email) async {
    await $.enterText($(K.auth.emailEntry), email);
  }

  Future<void> enterPassword(String password) async {
    await $.enterText($(K.auth.passwordEntry), password);
  }

  Future<void> enterConfirmPassword(String password) async {
    await $.enterText($(K.auth.confirmPasswordEntry), password);
  }

  Future<void> submitLogin() async {
    await $.tap($(K.auth.loginButton));
    await app.dismissSnackBar();
    await $.pumpAndSettle();
  }

  Future<void> submitSignup() async {
    await $.tap($(K.auth.signupButton));
    await app.dismissSnackBar();
    await $.pumpAndSettle();
  }
}
