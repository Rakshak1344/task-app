import 'package:app/features/tasks/data/models/task_filter.dart';
import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:app/features/tasks/services/task_filter_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_filter_state.g.dart';

@Riverpod(keepAlive: true)
class TaskFilterState extends _$TaskFilterState {
  TaskFilterService get _service => ref.read(taskFilterServiceProvider);

  /// The query is never persisted, so storage cannot be its source of truth —
  /// every filter coming back from disk gets the current query stamped on.
  String _query = '';

  @override
  Stream<TaskFilter> build() =>
      _service.watch().map((filter) => filter.copyWith(query: _query));

  Future<void> updateStatus(TaskStatus? status) =>
      _service.save(_current.copyWith(status: status));

  Future<void> updatePriority(TaskPriority? priority) =>
      _service.save(_current.copyWith(priority: priority));

  void updateQuery(String query) {
    _query = query;
    state = AsyncData(_current.copyWith(query: query));
  }

  /// Clears the stored filter only. The search field owns its own clear button,
  /// and it is not visible from the page this is called from.
  Future<void> clear() => _service.clear();

  TaskFilter get _current =>
      state.value ?? _service.get().copyWith(query: _query);

  static bool filterRequestChanged(
    AsyncValue<TaskFilter>? previous,
    AsyncValue<TaskFilter> next,
  ) {
    final before = previous?.value;
    final after = next.value;

    if (before == null || after == null) {
      return false;
    }

    return !before.sameRequestAs(after);
  }
}
