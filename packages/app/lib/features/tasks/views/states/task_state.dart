import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/services/task_service.dart';
import 'package:core/error/exception_adapter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_state.g.dart';

@Riverpod(keepAlive: true)
class TaskState extends _$TaskState {
  TaskService get _service => ref.read(taskServiceProvider);

  ExceptionAdapter get _exceptionAdapter => ref.read(exceptionAdapterProvider);

  @override
  Stream<List<Task>> build() => _service.watch();

  Future<void> fetchTasks({int page = 1, int perPage = 10}) async {
    await _exceptionAdapter
        .run(() async {
          await _service.fetchTasks(page: page, perPage: perPage);
        })
        .catchError((e, st) {
          state = AsyncError(e, st);
        });
  }
}
