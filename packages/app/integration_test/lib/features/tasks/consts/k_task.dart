import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';

class KTask {
  static const String title = 'Write the integration tests';
  static const String description = 'Cover the create flow end to end';

  static const TaskStatus status = TaskStatus.inProgress;
  static const TaskPriority priority = TaskPriority.high;
}
