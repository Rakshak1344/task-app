// ignore_for_file: avoid_relative_lib_imports

import 'package:app/features/auth/data/models/auth.dart';
import 'package:app/features/auth/data/models/user.dart';
import 'package:app/features/auth/repositories/local_auth_repository.dart';
import 'package:app/features/auth/repositories/local_user_repository.dart';
import 'package:app/features/auth/repositories/network_auth_repository.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:core/test/storage/store.dart';
import 'package:core/test/test_app.dart';

import '../lib/features/auth/consts/k_auth.dart';
import '../lib/features/auth/factories/user_factory.dart';
import '../lib/features/auth/repositories/fake_auth_network_repository.dart';

mixin TestAppAuth on TestApp {
  User? getLoggedInUser() => container.read(localUserRepositoryProvider).get();

  String? getAccessToken() => container.read(localAuthRepositoryProvider).get();

  User seedExistingUser({User? user}) {
    var seeded =
        user ?? UserFixture.factory().withEmail(KAuth.email).makeSingle();

    Store<User>().value = seeded;

    return seeded;
  }

  Future<User> setupWithExistingUser({User? user}) async {
    late User seeded;

    await setup(onInit: (_) async => seeded = seedExistingUser(user: user));

    return seeded;
  }

  Future<User> setupLoggedIn({User? user}) async {
    late User loggedIn;

    await setup(onInit: (_) async => loggedIn = await loginAsUser(user: user));

    return loggedIn;
  }

  Future<User> loginAsUser({User? user}) async {
    var authService = container.read(authServiceProvider);
    var fakeAuthRepository =
        container.read(networkAuthRepositoryProvider)
            as FakeAuthNetworkRepository;
    var existingUser = user ?? fakeAuthRepository.existingUser(KAuth.email);

    Store<User>().value = existingUser;

    await authService.updateUserAndToken(
      Auth(user: existingUser, accessToken: "valid-token"),
    );

    return existingUser;
  }
}
