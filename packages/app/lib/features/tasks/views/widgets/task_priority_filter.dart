import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/utils/keys.dart';
import 'package:flutter/material.dart';

class TaskPriorityFilter extends StatelessWidget {
  const TaskPriorityFilter({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TaskPriority? value;

  /// Emits `null` when the selected chip is tapped again.
  final ValueChanged<TaskPriority?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Priority', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TaskPriority.values.map((priority) {
            return FilterChip(
              key: K.tasks.priorityFilterChip(priority),
              label: Text(priority.label),
              selected: value == priority,
              onSelected: (isSelected) =>
                  onChanged(isSelected ? priority : null),
            );
          }).toList(),
        ),
      ],
    );
  }
}
