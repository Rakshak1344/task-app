import 'package:flutter/widgets.dart';

var taskKeys = TaskKeys();

class TaskKeys {
  TaskKeys();

  /// Task list page
  final createButton = const Key('tasks.create.button');

  /// Task card — keyed per task, since cards repeat
  Key tile(int taskId) => Key('tasks.tile.$taskId');

  Key tileMoreButton(int taskId) => Key('tasks.tile.more.$taskId');

  final tileEditOption = const Key('tasks.tile.edit.option');
  final tileDeleteOption = const Key('tasks.tile.delete.option');

  /// Delete confirmation dialog
  final deleteConfirmButton = const Key('tasks.delete.confirm.button');
  final deleteCancelButton = const Key('tasks.delete.cancel.button');

  /// Task form page
  final titleEntry = const Key('tasks.form.title.entry');
  final descriptionEntry = const Key('tasks.form.description.entry');
  final statusDropdown = const Key('tasks.form.status.dropdown');
  final priorityDropdown = const Key('tasks.form.priority.dropdown');
  final submitButton = const Key('tasks.form.submit.button');
}
