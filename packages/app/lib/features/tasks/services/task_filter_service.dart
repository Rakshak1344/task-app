import 'package:app/features/tasks/data/models/task_filter.dart';
import 'package:app/features/tasks/repositories/local_task_filter_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_filter_service.g.dart';

@Riverpod(keepAlive: true)
TaskFilterService taskFilterService(Ref ref) => TaskFilterService(ref);

class TaskFilterService {
  TaskFilterService(this.ref)
    : _localRepository = ref.read(localTaskFilterRepositoryProvider);

  final Ref ref;
  final LocalTaskFilterRepository _localRepository;

  /// Nothing stored reads as an empty filter, so consumers never null-check.
  Stream<TaskFilter> watch() =>
      _localRepository.watch().map((filter) => filter ?? const TaskFilter());

  TaskFilter get() => _localRepository.get() ?? const TaskFilter();

  Future<void> save(TaskFilter filter) => _localRepository.save(filter);

  Future<void> clear() => _localRepository.delete();
}
