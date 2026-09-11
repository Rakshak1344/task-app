import 'dart:convert';

import 'package:app/storage/const/box_name.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';

class HivePreference extends Preferences {
  static final String _preferencesBox = BoxName.preferences;
  static const String _encryptionKeyName = 'encryptionKey';

  final Box<dynamic> _box;

  static HivePreference? _preference;

  HivePreference._(this._box);

  // This doesn't have to be a singleton.
  // We just want to make sure that the box is open, before we start
  // getting/setting objects on it.
  static Future<HivePreference> getInstance() async {
    if (_preference != null) {
      return _preference!;
    }

    final key = await _readOrCreateEncryptionKey();

    final box = await _openBox(key);
    await box.flush();

    _preference = HivePreference._(box);

    return _preference!;
  }

  static Future<Uint8List> _readOrCreateEncryptionKey() async {
    const secureStorage = FlutterSecureStorage();

    var encryptionKey = await secureStorage.read(key: _encryptionKeyName);
    if (encryptionKey == null) {
      encryptionKey = base64Url.encode(Hive.generateSecureKey());
      await secureStorage.write(key: _encryptionKeyName, value: encryptionKey);
    }

    return base64Url.decode(encryptionKey);
  }

  /// Opens the encrypted box, recreating it if the stored key no longer
  /// decrypts it.
  ///
  /// Losing the keystore entry (an OS upgrade, "clear credentials") leaves a
  /// box on disk that the freshly generated key cannot read. Without this
  /// fallback `openBox` throws and the app hangs on the splash screen forever.
  /// Wiping the box logs the user out, which is recoverable; hanging is not.
  static Future<Box<dynamic>> _openBox(Uint8List key) async {
    try {
      return await Hive.openBox<dynamic>(
        _preferencesBox,
        encryptionCipher: HiveAesCipher(key),
      );
    } catch (_) {
      await Hive.deleteBoxFromDisk(_preferencesBox);
      return Hive.openBox<dynamic>(
        _preferencesBox,
        encryptionCipher: HiveAesCipher(key),
      );
    }
  }

  @override
  T? getValue<T>(String key, {T? defaultValue}) =>
      _box.get(key, defaultValue: defaultValue) as T?;

  @override
  Stream<T?> watchValue<T>(String key) {
    return _box.watch(key: key).map((BoxEvent event) => getValue(key));
  }

  @override
  Future<void> setValue<T>(String key, T value) => _box.put(key, value);

  @override
  Future<void> clear() async {
    await _box.deleteAll(_box.keys);
  }

  @override
  Future<void> remove(String key) {
    return _box.delete(key);
  }
}
