import 'package:json_annotation/json_annotation.dart';

enum TaskPriority {
  @JsonValue('low')
  low('low', 'Low'),
  @JsonValue('medium')
  medium('medium', 'Medium'),
  @JsonValue('high')
  high('high', 'High');

  const TaskPriority(this.value, this.label);

  final String value;
  final String label;
}
