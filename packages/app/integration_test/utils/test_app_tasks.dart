import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/repositories/local_task_repository.dart';
import 'package:core/test/test_app.dart';

mixin TestAppTasks on TestApp {
  List<Task> getTasks() => container.read(localTaskRepositoryProvider).get();
}
