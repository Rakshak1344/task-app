import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/services/task_service.dart';
import 'package:core/error/exception_adapter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_detail_state.g.dart';

@riverpod
class TaskDetailState extends _$TaskDetailState {
  TaskService get _service => ref.read(taskServiceProvider);

  ExceptionAdapter get _exceptionAdapter => ref.read(exceptionAdapterProvider);

  @override
  Stream<Task?> build(int taskId) => _service.watchOneById(taskId);

  Future<void> fetchTask() async {
    await _exceptionAdapter
        .run(() async {
          await _service.fetchTaskById(taskId);
        })
        .catchError((e, st) {
          state = AsyncError(e, st);
        });
  }
}
