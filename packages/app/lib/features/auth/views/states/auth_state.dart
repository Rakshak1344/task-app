import 'package:app/features/auth/services/auth_service.dart';
import 'package:core/error/exception_adapter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state.g.dart';

@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  AuthService get _authService => ref.read(authServiceProvider);

  ExceptionAdapter get _exceptionAdapter => ref.read(exceptionAdapterProvider);

  @override
  Stream<String?> build() => ref.watch(authServiceProvider).watch();

  Future<void> logout() async {
    try {
      await _exceptionAdapter.run(() => _authService.logout());
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
