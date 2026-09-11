import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'preference.g.dart';

/// Deliberately unimplemented. The concrete storage lives in the app package,
/// which overrides this provider in [ProviderScope] once the backing store has
/// been opened. See `TaskAppConfig.overrides()`.
@riverpod
Preferences preference(Ref ref) => throw UnimplementedError();

/// A key/value store for small, primitive values.
///
/// Kept free of any storage-specific types so the app package can swap the
/// implementation (Hive today) without touching consumers.
abstract class Preferences {
  T? getValue<T>(String key, {T? defaultValue});

  Future<void> setValue<T>(String key, T value);

  /// Emits whenever [key] is written to or removed.
  Stream<T?> watchValue<T>(String key);

  Future<void> clear();

  Future<void> remove(String key);
}
