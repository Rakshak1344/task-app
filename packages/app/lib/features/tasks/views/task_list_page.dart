import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/views/states/task_form_state.dart';
import 'package:app/features/tasks/views/states/task_state.dart';
import 'package:app/features/tasks/views/widgets/delete_task_dialog.dart';
import 'package:app/features/tasks/views/widgets/task_list_tile.dart';
import 'package:app/navigation/app_route_name.dart';
import 'package:app/utils/keys.dart';
import 'package:app/utils/snackbar.dart';
import 'package:core/error/exceptions/interfaces/renderable_exception.dart';
import 'package:core/error/exceptions/no_more_data_exception.dart';
import 'package:core/ui/extensions/async_value_extension.dart';
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

  void listenTaskState() {
    ref.listen(taskStateProvider, (previous, next) {
      final error = next.error;

      if (error is NoMoreDataException) {
        setState(() => _hasMore = false);
        return;
      }
    });
  }

  void listenTaskFormState() {
    ref.listen(taskFormStateProvider, (previous, next) {
      if (previous?.isLoading != true) {
        return;
      }

      /// Shared with [TaskFormPage], which sits above this route while saving —
      /// only report a result the list itself started.
      if (ModalRoute.of(context)?.isCurrent != true) {
        return;
      }

      context.showSnackBar(
        next.hasError ? 'Failed to delete task' : 'Task deleted',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    listenTaskState();
    listenTaskFormState();

    var state = ref.watch(taskStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My tasks'),
        actions: [buildIconButton(context)],
      ),
      floatingActionButton: buildCreateTaskFloatingActionButton(context),
      body: state.whenDataWithErrorFallback(
        data: (List<Task> tasks) => buildTasksView(tasks),
        error: (Object e, StackTrace st) =>
            RenderableException.renderAny(e, st),
        emptyOrNull: () => buildTasksView(const <Task>[]),
        loading: () => state.hasValue && state.value!.isNotEmpty
            ? buildTasksView(state.value!)
            : context.showLoading(),
        onRetry: _onPullToRefreshTasks,
      ),
    );
  }

  Widget buildTasksView(List<Task> tasks) {
    return PaginatedListView<Task>(
      items: tasks,
      hasMore: _hasMore,
      noMoreItemsText: tasks.isEmpty ? 'No tasks yet' : 'No more tasks',
      onRefresh: _onPullToRefreshTasks,
      updatePageNumber: (int? value) async => _fetchTasks(),
      buildItem: buildTask,
    );
  }

  FloatingActionButton buildCreateTaskFloatingActionButton(
    BuildContext context,
  ) {
    return FloatingActionButton.extended(
      key: K.tasks.createButton,
      onPressed: () => context.pushNamed(AppRouteName.tasks.create),
      icon: const Icon(Icons.add),
      label: const Text('New task'),
    );
  }

  IconButton buildIconButton(BuildContext context) {
    return IconButton(
      key: K.profile.openButton,
      icon: const Icon(Icons.account_circle_outlined),
      tooltip: 'Profile',
      onPressed: () => context.pushNamed(AppRouteName.profile.profile),
    );
  }

  Widget buildTask(Task task) {
    return TaskListTile(
      task: task,
      onTap: () {
        context.pushNamed(
          AppRouteName.tasks.edit,
          pathParameters: {'id': task.id.toString()},
        );
      },
      onDelete: () => _confirmDelete(task),
    );
  }

  void _fetchTasks() {
    ref.read(taskStateProvider.notifier).fetchTasks(_page);
    setState(() => _page++);
  }

  Future<void> _onPullToRefreshTasks() async {
    _page = 1;
    _fetchTasks();
    setState(() => _hasMore = true);
  }

  Future<void> _confirmDelete(Task task) async {
    final shouldDelete = await DeleteTaskDialog.show(context, task);

    if (shouldDelete != true) {
      return;
    }

    await ref.read(taskFormStateProvider.notifier).delete(task.id);
  }
}
