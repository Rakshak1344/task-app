import 'package:app/features/auth/services/auth_service.dart';
import 'package:core/error/exception_adapter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signup_state.g.dart';

@riverpod
class SignupState extends _$SignupState {
  AuthService get _authService => ref.read(authServiceProvider);

  ExceptionAdapter get _exceptionAdapter => ref.read(exceptionAdapterProvider);

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      await _exceptionAdapter.run(
        () => _authService.signup(name, email, password),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
