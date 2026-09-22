import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:app/features/tasks/repositories/local_task_repository.dart';
import 'package:app/features/tasks/repositories/network_task_repository.dart';
import 'package:core/error/exceptions/no_more_data_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_service.g.dart';

@Riverpod(keepAlive: true)
TaskService taskService(Ref ref) => TaskService(ref);

class TaskService {
  TaskService(this.ref)
    : _networkRepository = ref.read(networkTaskRepositoryProvider),
      _localRepository = ref.read(localTaskRepositoryProvider);

  final Ref ref;
  final NetworkTaskRepository _networkRepository;
  final LocalTaskRepository _localRepository;

  Stream<List<Task>> watch() => _localRepository.watch();

  Stream<Task?> watchOneById(int taskId) =>
      _localRepository.watchOneById(taskId);

  Future<void> fetchTasks({int page = 1, int perPage = 10}) async {
    final response = await _networkRepository.index(page, perPage);

    if (page == 1) {
      await _localRepository.deleteAll();
    }

    await _localRepository.save(response.data);

    if (response.meta.currentPage >= response.meta.lastPage) {
      throw NoMoreDataException();
    }
  }

  Future<void> fetchTaskById(int taskId) async {
    final response = await _networkRepository.show(taskId);
    await _localRepository.saveOne(response.data);
  }

  Future<Task> create({
    required String title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
  }) async {
    final response = await _networkRepository.store(
      title,
      description,
      status?.value,
      priority?.value,
      _formatDueDate(dueDate),
    );

    await _localRepository.saveOne(response.data);

    return response.data;
  }

  Future<Task> update({
    required int id,
    required String title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
  }) async {
    final response = await _networkRepository.update(
      id,
      title,
      description,
      status?.value,
      priority?.value,
      _formatDueDate(dueDate),
    );

    await _localRepository.saveOne(response.data);

    return response.data;
  }

  Future<void> delete(int id) async {
    await _networkRepository.destroy(id);
    await _localRepository.deleteById(id);
  }

  Future<void> clearAll() => _localRepository.deleteAll();

  String? _formatDueDate(DateTime? dueDate) =>
      dueDate?.toUtc().toIso8601String();
}
