import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:app/utils/keys.dart';
import 'package:flutter/material.dart';

class TaskStatusFilter extends StatelessWidget {
  const TaskStatusFilter({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TaskStatus? value;

  /// Emits `null` when the selected chip is tapped again.
  final ValueChanged<TaskStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TaskStatus.values.map((status) {
            return FilterChip(
              key: K.tasks.statusFilterChip(status),
              label: Text(status.label),
              selected: value == status,
              onSelected: (isSelected) => onChanged(isSelected ? status : null),
            );
          }).toList(),
        ),
      ],
    );
  }
}
