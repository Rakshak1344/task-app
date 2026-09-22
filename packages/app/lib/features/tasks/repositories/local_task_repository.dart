import 'dart:async';
import 'dart:convert';

import 'package:app/features/tasks/data/models/task.dart';
import 'package:core/arch/repository.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_task_repository.g.dart';

@Riverpod(keepAlive: true)
LocalTaskRepository localTaskRepository(Ref ref) => LocalTaskRepository(ref);

class LocalTaskRepository extends CollectionRepository<Task> {
  LocalTaskRepository(this.ref);

  final Ref ref;

  Preferences get sharedPreferences => ref.read(preferenceProvider);

  final StreamController<List<Task>> _controller =
      StreamController<List<Task>>();

  late final Stream<List<Task>> _stream = _controller.stream
      .asBroadcastStream();

  StreamSubscription<String?>? _subscription;

  static const _key = 'tasks';

  @override
  Stream<List<Task>> watch() {
    _subscription ??= sharedPreferences
        .watchValue<String?>(_key)
        .listen((value) => _controller.add(_decode(value)));

    _controller.add(get());

    return _stream;
  }

  Stream<Task?> watchOneById(int taskId) =>
      watch().map((tasks) => tasks.where((t) => t.id == taskId).firstOrNull);

  @override
  List<Task> get() => _decode(sharedPreferences.getValue<String?>(_key));

  @override
  Future<void> save(List<Task> data) async {
    final merged = <int, Task>{for (final task in get()) task.id: task};
    for (final task in data) {
      merged[task.id] = task;
    }

    await _write(merged.values.toList());
  }

  Future<void> saveOne(Task data) async {
    final tasks = get();
    final index = tasks.indexWhere((task) => task.id == data.id);

    if (index == -1) {
      tasks.insert(0, data);
    } else {
      tasks[index] = data;
    }

    await _write(tasks);
  }

  @override
  Future<void> delete(Task data) => deleteById(data.id);

  Future<void> deleteById(int taskId) async {
    final tasks = get()..removeWhere((task) => task.id == taskId);
    await _write(tasks);
  }

  @override
  Future<void> deleteAll() => sharedPreferences.remove(_key);

  Future<void> _write(List<Task> tasks) {
    return sharedPreferences.setValue(
      _key,
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
  }

  List<Task> _decode(String? value) {
    if (value == null) {
      return [];
    }

    return (jsonDecode(value) as List)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
