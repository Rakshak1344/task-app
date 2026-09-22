import 'package:app/features/auth/data/models/auth.dart';
import 'package:app/features/auth/data/models/user.dart';
import 'package:app/features/auth/repositories/network_auth_repository.dart';
import 'package:core/data/response.dart';
import 'package:core/test/storage/has_store.dart';
import 'package:dio/dio.dart';

import '../../../../support/fake_errors.dart';
import '../consts/k_auth.dart';
import '../factories/auth_factory.dart';
import '../factories/user_factory.dart';

class FakeAuthNetworkRepository
    with HasStore<User>
    implements NetworkAuthRepository {
  FakeAuthNetworkRepository({this.validPassword = KAuth.password})
    : _error = null;

  FakeAuthNetworkRepository.unauthorized({this.validPassword = KAuth.password})
    : _error = unauthorizedError();

  FakeAuthNetworkRepository.invalid(
    Map<String, List<String>> errors, {
    this.validPassword = KAuth.password,
  }) : _error = validationError(errors);

  final String validPassword;
  final DioException? _error;

  static const String invalidCredentialsMessage =
      'These credentials do not match our records.';

  static const String emailTakenMessage = 'The email has already been taken.';

  @override
  Future<ObjectResponse<Auth>> login(String email, String password) async {
    _maybeThrow();

    if (password != validPassword) {
      throw validationError({
        'email': [invalidCredentialsMessage],
      });
    }

    return ObjectResponse(_authFor(email));
  }

  @override
  Future<ObjectResponse<Auth>> signup(
    String name,
    String email,
    String password,
  ) async {
    _maybeThrow();

    if (store.value?.email == email) {
      throw validationError({
        'email': [emailTakenMessage],
      });
    }

    return ObjectResponse(_authFor(email));
  }

  @override
  Future<void> logout() async => _maybeThrow();

  User existingUser(String email) {
    final current = store.value;
    if (current != null && current.email == email) {
      return current;
    }

    return store.value = UserFixture.factory().withEmail(email).makeSingle();
  }

  Auth _authFor(String email) =>
      AuthFixture.factory().withUser(existingUser(email)).makeSingle();

  void _maybeThrow() {
    final error = _error;
    if (error != null) {
      throw error;
    }
  }
}
