import 'package:app/features/tasks/data/models/task_filter.dart';
import 'package:app/features/tasks/views/states/task_filter_state.dart';
import 'package:app/features/tasks/views/widgets/task_priority_filter.dart';
import 'package:app/features/tasks/views/widgets/task_status_filter.dart';
import 'package:app/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskFilterPage extends ConsumerWidget {
  const TaskFilterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter =
        ref.watch(taskFilterStateProvider).value ?? const TaskFilter();
    final notifier = ref.read(taskFilterStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Tasks'),
        actions: [
          if (!filter.isEmpty)
            TextButton(
              key: K.tasks.clearFiltersButton,
              onPressed: notifier.clear,
              child: const Text('Clear'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskStatusFilter(
              value: filter.status,
              onChanged: notifier.updateStatus,
            ),
            const SizedBox(height: 24),
            TaskPriorityFilter(
              value: filter.priority,
              onChanged: notifier.updatePriority,
            ),
          ],
        ),
      ),
    );
  }
}
