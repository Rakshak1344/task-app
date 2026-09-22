import 'package:app/features/auth/data/models/auth.dart';
import 'package:app/features/auth/repositories/local_auth_repository.dart';
import 'package:app/features/auth/repositories/local_user_repository.dart';
import 'package:app/features/auth/repositories/network_auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) => AuthService(ref);

class AuthService {
  final Ref ref;
  final NetworkAuthRepository _networkAuthRepository;
  final LocalAuthRepository _localAuthRepository;
  final LocalUserRepository _localUserRepository;

  AuthService(this.ref)
    : _networkAuthRepository = ref.read(networkAuthRepositoryProvider),
      _localAuthRepository = ref.read(localAuthRepositoryProvider),
      _localUserRepository = ref.read(localUserRepositoryProvider);

  // watch auth state changes
  Stream<String?> watch() => _localAuthRepository.watch();

  Future<void> login(String email, String password) async {
    final response = await _networkAuthRepository.login(email, password);

    await updateUserAndToken(response.data);
  }

  Future<void> signup(String name, String email, String password) async {
    final response = await _networkAuthRepository.signup(name, email, password);

    await updateUserAndToken(response.data);
  }

  Future<void> updateUserAndToken(Auth auth) async {
    await _localUserRepository.save(auth.user);
    await _localAuthRepository.save(auth.accessToken);
  }

  Future<void> logout() async {
    await _localAuthRepository.delete();
    await _localUserRepository.delete();
  }
}
