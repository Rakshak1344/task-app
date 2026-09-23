import 'dart:async';

import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/data/models/task_filter.dart';
import 'package:app/features/tasks/services/task_service.dart';
import 'package:app/features/tasks/views/states/task_filter_state.dart';
import 'package:core/error/exception_adapter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_state.g.dart';

@Riverpod(keepAlive: true)
class TaskState extends _$TaskState {
  TaskService get _service => ref.read(taskServiceProvider);

  ExceptionAdapter get _exceptionAdapter => ref.read(exceptionAdapterProvider);

  static const _searchDebounce = Duration(milliseconds: 1000);

  int _page = 0;
  Timer? _debounce;

  @override
  Stream<List<Task>> build() {
    ref.listen(taskFilterStateProvider, _onFilterChanged);
    ref.onDispose(() => _debounce?.cancel());

    return _service.watch();
  }

  /// The filter is part of the request, so changing it means reloading from the
  /// first page rather than filtering what happens to be cached.
  void _onFilterChanged(
    AsyncValue<TaskFilter>? previous,
    AsyncValue<TaskFilter> next,
  ) {
    if (!TaskFilterState.filterRequestChanged(previous, next)) {
      return;
    }

    _debounce?.cancel();

    /// Typing waits for a pause so one request goes out per pause; picking a
    /// chip is a deliberate single action and reloads straight away.
    if (previous?.value?.searchTerm != next.value?.searchTerm) {
      _debounce = Timer(_searchDebounce, refresh);
      return;
    }

    refresh();
  }

  Future<void> refresh() => _fetch(1);

  Future<void> fetchNextPage() => _fetch(_page + 1);

  Future<void> _fetch(int page) async {
    await _exceptionAdapter
        .run(() async {
          await _service.fetchTasks(page: page, filter: _filter);
        })
        .catchError((e, st) {
          state = AsyncError(e, st);
        });

    _page = page;
  }

  TaskFilter? get _filter => ref.read(taskFilterStateProvider).value;
}
