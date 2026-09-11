import 'dart:async';

import 'package:app/storage/const/preference_keys.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_auth_repository.g.dart';

@Riverpod(keepAlive: true)
LocalAuthRepository localAuthRepository(Ref ref) {
  return LocalAuthRepository(ref);
}

class LocalAuthRepository {
  LocalAuthRepository(this.ref);

  final Ref ref;

  Preferences get sharedPreference => ref.read(preferenceProvider);

  final _controller = StreamController<String?>();
  final key = PreferenceKeys.accessToken;

  // create / update
  Future<void> save(String? data) {
    if (data == null) {
      return sharedPreference.remove(key);
    }

    return sharedPreference.setValue(key, data);
  }


  Stream<String?> watch() {
    sharedPreference
        .watchValue<String?>(key)
        .listen(updateAuthTokenToController);

    _controller.add(get());

    return _controller.stream.asBroadcastStream();
  }

  void updateAuthTokenToController(String? authToken) {
    _controller.add(authToken);
  }

  String? get() {
    return sharedPreference.getValue<String?>(key);
  }

  Future<void> delete() async {
    await sharedPreference.remove(key);
  }

  Future<void> clear() async {
    await sharedPreference.clear();
  }
}
