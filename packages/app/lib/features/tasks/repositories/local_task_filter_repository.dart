import 'dart:async';
import 'dart:convert';

import 'package:app/features/tasks/data/models/task_filter.dart';
import 'package:app/storage/const/preference_keys.dart';
import 'package:core/arch/repository.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_task_filter_repository.g.dart';

@Riverpod(keepAlive: true)
LocalTaskFilterRepository localTaskFilterRepository(Ref ref) =>
    LocalTaskFilterRepository(ref);

class LocalTaskFilterRepository extends ObjectRepository<TaskFilter> {
  LocalTaskFilterRepository(this.ref);

  final Ref ref;

  Preferences get sharedPreferences => ref.read(preferenceProvider);

  final StreamController<TaskFilter?> _controller =
      StreamController<TaskFilter?>();

  late final Stream<TaskFilter?> _stream = _controller.stream
      .asBroadcastStream();

  StreamSubscription<String?>? _subscription;

  final key = PreferenceKeys.taskFilter;

  @override
  Stream<TaskFilter?> watch() {
    _subscription ??= sharedPreferences
        .watchValue<String?>(key)
        .listen((value) => _controller.add(_decode(value)));

    _controller.add(get());

    return _stream;
  }

  @override
  TaskFilter? get() => _decode(sharedPreferences.getValue<String?>(key));

  @override
  Future<void> save(TaskFilter? data) {
    if (data == null) {
      return sharedPreferences.remove(key);
    }

    return sharedPreferences.setValue(key, jsonEncode(data.toJson()));
  }

  @override
  Future<void> delete() => sharedPreferences.remove(key);

  TaskFilter? _decode(String? value) {
    if (value == null) {
      return null;
    }

    return TaskFilter.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }
}
