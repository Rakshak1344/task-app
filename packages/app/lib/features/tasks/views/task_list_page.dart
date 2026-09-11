import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/views/states/task_form_state.dart';
import 'package:app/features/tasks/views/states/task_state.dart';
import 'package:app/features/tasks/views/widgets/task_list_tile.dart';
import 'package:app/navigation/app_route_name.dart';
import 'package:core/error/exceptions/no_more_data_exception.dart';
import 'package:core/ui/paginated_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});

  @override
  ConsumerState createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  int _page = 1;
  bool _hasMore = true;
  bool _isFetching = false;
  List<Task> _tasks = const <Task>[];

  void listenTaskState() {
    ref.listen(taskStateProvider, (previous, next) {
      final error = next.error;

      if (error is NoMoreDataException) {
        if (_hasMore) {
          setState(() => _hasMore = false);
        }
        return;
      }

      if (!next.hasError || error == null) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              "Failed to load tasks.\n$error",
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
            duration: const Duration(seconds: 8),
          ),
        );
    });
  }

  Future<void> _fetch(int page) async {
    if (_isFetching) {
      return;
    }

    _isFetching = true;
    _page = page;

    try {
      await ref.read(taskStateProvider.notifier).fetchTasks(page: page);
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _updatePageNumber(int? page) async {
    if (page != null) {
      if (_hasMore != true) {
        setState(() => _hasMore = true);
      }
      await _fetch(page);
      return;
    }

    if (!_hasMore) {
      return;
    }

    await _fetch(_page + 1);
  }

  Future<void> _onRefresh() async {
    if (!_hasMore) {
      setState(() => _hasMore = true);
    }
    await _fetch(1);
  }

  Future<void> _confirmDelete(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task'),
        content: Text('Delete "${task.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final deleted = await ref
        .read(taskFormStateProvider.notifier)
        .delete(task.id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(deleted ? 'Task deleted' : 'Failed to delete task'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    listenTaskState();

    final state = ref.watch(taskStateProvider);

    final emitted = state.value;
    if (emitted != null) {
      _tasks = emitted;
    }
    final tasks = _tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile',
            onPressed: () => context.pushNamed(AppRouteName.profile.profile),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRouteName.tasks.create),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
      body: PaginatedListView<Task>(
        items: tasks,
        hasMore: _hasMore,
        noMoreItemsText: tasks.isEmpty ? 'No tasks yet' : 'No more tasks',
        onRefresh: _onRefresh,
        updatePageNumber: _updatePageNumber,
        buildItem: (task) => TaskListTile(
          task: task,
          onTap: () => context.pushNamed(
            AppRouteName.tasks.edit,
            pathParameters: {'id': task.id.toString()},
          ),
          onDelete: () => _confirmDelete(task),
        ),
      ),
    );
  }
}
