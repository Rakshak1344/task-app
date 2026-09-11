import 'dart:async';
import 'dart:convert';

import 'package:app/features/auth/data/models/user.dart';
import 'package:app/storage/const/preference_keys.dart';
import 'package:core/arch/repository.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_user_repository.g.dart';

@Riverpod(keepAlive: true)
LocalUserRepository localUserRepository(Ref ref) => LocalUserRepository(ref);

class LocalUserRepository extends ObjectRepository<User> {
  LocalUserRepository(this.ref);

  final Ref ref;

  Preferences get sharedPreference => ref.read(preferenceProvider);

  final StreamController<User?> _controller = StreamController<User?>();
  final key = PreferenceKeys.user;

  @override
  Stream<User?> watch() {
    sharedPreference.watchValue<String?>(key).listen(updateUserToController);

    _controller.add(get());

    return _controller.stream.asBroadcastStream();
  }

  @override
  Future<void> save(User? data) {
    if (data == null) {
      return sharedPreference.remove(key);
    }

    return sharedPreference.setValue(key, json.encode(data.toJson()));
  }

  void updateUserToController(String? userString) {
    if (userString == null) {
      _controller.add(null);
      return;
    }

    _controller.add(User.fromJson(json.decode(userString)));
  }

  @override
  User? get() {
    var userString = sharedPreference.getValue<String?>(key);
    if (userString == null) {
      return null;
    }

    return User.fromJson(json.decode(userString));
  }

  @override
  Future<void> delete() async {
    await sharedPreference.remove(key);
  }
}
