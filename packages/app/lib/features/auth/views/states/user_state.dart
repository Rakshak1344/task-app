import 'package:app/features/auth/data/models/user.dart';
import 'package:app/features/auth/repositories/local_user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_state.g.dart';

/// The persisted user, kept in step with [AuthState] by the same storage
/// writes. Read-only — logging in/out goes through `authStateProvider`.
@Riverpod(keepAlive: true)
class UserState extends _$UserState {
  @override
  Stream<User?> build() => ref.watch(localUserRepositoryProvider).watch();
}
