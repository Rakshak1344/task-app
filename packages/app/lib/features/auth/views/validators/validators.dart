class AuthValidators {
  const AuthValidators._();

  static String? name(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Confirm-password is a client-side check only — it is never sent to the API.
  static String? confirmPassword(String? value, {required String password}) {
    final confirmation = value ?? '';
    if (confirmation.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmation != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
