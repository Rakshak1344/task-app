import 'package:app/features/auth/data/models/user.dart';
import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

part 'task.g.dart';

@freezed
sealed class Task with _$Task {
  const Task._();

  const factory Task({
    required int id,
    required String title,
    String? description,
    @JsonKey(unknownEnumValue: TaskStatus.pending)
    @Default(TaskStatus.pending)
    TaskStatus status,
    @JsonKey(unknownEnumValue: TaskPriority.medium)
    @Default(TaskPriority.medium)
    TaskPriority priority,
    DateTime? dueDate,
    User? user,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  bool get isOverdue {
    final due = dueDate;
    if (due == null || status == TaskStatus.completed) {
      return false;
    }
    return due.isBefore(DateTime.now());
  }
}