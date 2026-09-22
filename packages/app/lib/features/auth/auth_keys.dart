import 'package:flutter/widgets.dart';

var authKeys = AuthKeys();

class AuthKeys {
  AuthKeys();

  /// Login page
  final emailEntry = const Key('auth.email.entry');
  final passwordEntry = const Key('auth.password.entry');
  final loginButton = const Key('auth.login.button');
  final createAccountButton = const Key('auth.createAccount.button');

  /// Signup page
  final nameEntry = const Key('auth.name.entry');
  final confirmPasswordEntry = const Key('auth.confirmPassword.entry');
  final signupButton = const Key('auth.signup.button');
}
