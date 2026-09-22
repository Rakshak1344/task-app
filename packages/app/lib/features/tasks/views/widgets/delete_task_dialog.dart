import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/utils/keys.dart';
import 'package:flutter/material.dart';

class DeleteTaskDialog extends StatelessWidget {
  const DeleteTaskDialog({super.key, required this.task});

  final Task task;

  /// Resolves to `true` only when the user confirms — `false` on cancel and
  /// `null` when the dialog is dismissed by tapping outside it.
  static Future<bool?> show(BuildContext context, Task task) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteTaskDialog(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete task'),
      content: Text('Delete "${task.title}"? This cannot be undone.'),
      actions: [
        TextButton(
          key: K.tasks.deleteCancelButton,
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: K.tasks.deleteConfirmButton,
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
