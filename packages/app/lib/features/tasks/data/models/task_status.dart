import 'package:json_annotation/json_annotation.dart';

enum TaskStatus {
  @JsonValue('pending')
  pending('pending', 'Pending'),
  @JsonValue('in_progress')
  inProgress('in_progress', 'In progress'),
  @JsonValue('completed')
  completed('completed', 'Completed');

  const TaskStatus(this.value, this.label);

  final String value;
  final String label;
}
