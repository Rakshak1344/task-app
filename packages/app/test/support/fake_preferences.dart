import 'dart:async';

import 'package:core/arch/storage/preference.dart';

/// In-memory stand-in for `HivePreference`, so tests don't need a real box or
/// the secure-storage plugin.
class FakePreferences extends Preferences {
  FakePreferences([Map<String, dynamic>? seed]) {
    if (seed != null) {
      _store.addAll(seed);
    }
  }

  final Map<String, dynamic> _store = {};
  final _controller = StreamController<String>.broadcast();

  @override
  T? getValue<T>(String key, {T? defaultValue}) =>
      (_store[key] ?? defaultValue) as T?;

  @override
  Future<void> setValue<T>(String key, T value) async {
    _store[key] = value;
    _controller.add(key);
  }

  @override
  Stream<T?> watchValue<T>(String key) => _controller.stream
      .where((changed) => changed == key)
      .map((_) => getValue<T>(key));

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
    _controller.add(key);
  }

  @override
  Future<void> clear() async {
    final keys = _store.keys.toList();
    _store.clear();
    for (final key in keys) {
      _controller.add(key);
    }
  }
}
