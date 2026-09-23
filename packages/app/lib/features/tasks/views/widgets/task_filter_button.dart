import 'package:app/utils/keys.dart';
import 'package:flutter/material.dart';

class TaskFilterButton extends StatelessWidget {
  const TaskFilterButton({
    super.key,
    required this.count,
    required this.onPressed,
  });

  /// How many filters are applied. No badge is rendered at zero.
  final int count;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      key: K.tasks.filterButton,
      icon: const Icon(Icons.filter_list),
      tooltip: 'Filter tasks',
      onPressed: onPressed,
    );

    if (count == 0) {
      return button;
    }

    return Badge.count(key: K.tasks.filterBadge, count: count, child: button);
  }
}
