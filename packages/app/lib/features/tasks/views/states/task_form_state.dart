import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:app/features/tasks/services/task_service.dart';
import 'package:core/error/exception_adapter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_form_state.g.dart';

@riverpod
class TaskFormState extends _$TaskFormState {
  TaskService get _service => ref.read(taskServiceProvider);

  ExceptionAdapter get _exceptionAdapter => ref.read(exceptionAdapterProvider);

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<Task?> save({
    int? id,
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    DateTime? dueDate,
  }) async {
    state = const AsyncLoading();

    try {
      final task = await _exceptionAdapter.run(() {
        if (id == null) {
          return _service.create(
            title: title,
            description: description,
            status: status,
            priority: priority,
            dueDate: dueDate,
          );
        }

        return _service.update(
          id: id,
          title: title,
          description: description,
          status: status,
          priority: priority,
          dueDate: dueDate,
        );
      });

      state = const AsyncData(null);
      return task;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> delete(int id) async {
    state = const AsyncLoading();

    try {
      await _exceptionAdapter.run(() => _service.delete(id));
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}