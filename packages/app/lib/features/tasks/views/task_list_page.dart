import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/data/models/task_filter.dart';
import 'package:app/features/tasks/views/states/task_filter_state.dart';
import 'package:app/features/tasks/views/states/task_form_state.dart';
import 'package:app/features/tasks/views/states/task_state.dart';
import 'package:app/features/tasks/views/widgets/delete_task_dialog.dart';
import 'package:app/features/tasks/views/widgets/task_filter_button.dart';
import 'package:app/features/tasks/views/widgets/task_list_tile.dart';
import 'package:app/features/tasks/views/widgets/task_search_field.dart';
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

  void listenTaskFilterState() {
    ref.listen(taskFilterStateProvider, (previous, next) {
      if (!TaskFilterState.filterRequestChanged(previous, next)) {
        return;
      }

      /// [TaskState] reloads the list itself; this only resets the paging
      /// footer, which lives here because [PaginatedListView] takes it as a
      /// parameter. Without it, filtering after reaching the end of the old
      /// list would keep claiming there is nothing more to load.
      setState(() => _hasMore = true);
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
    listenTaskFilterState();
    listenTaskFormState();
    var state = ref.watch(taskStateProvider);
    var filter = ref.watch(taskFilterStateProvider).value ?? const TaskFilter();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My tasks'),
        actions: [buildIconButton(context)],
      ),
      floatingActionButton: buildCreateTaskFloatingActionButton(context),
      body: Column(
        children: [
          buildSearchRow(context, filter),

          /// The list is the only part that swaps out per async state, so the
          /// search row stays put while loading or on error.
          Expanded(
            child: state.whenDataWithErrorFallback(
              data: (List<Task> tasks) => buildTasksView(tasks, filter),
              error: (Object e, StackTrace st) =>
                  RenderableException.renderAny(e, st),
              emptyOrNull: () => buildTasksView(const <Task>[], filter),
              loading: () => state.hasValue && state.value!.isNotEmpty
                  ? buildTasksView(state.value!, filter)
                  : context.showLoading(),
              onRetry: _onPullToRefreshTasks,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchRow(BuildContext context, TaskFilter filter) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: TaskSearchField(
              value: filter.query,
              onChanged: ref.read(taskFilterStateProvider.notifier).updateQuery,
            ),
          ),
          const SizedBox(width: 8),
          TaskFilterButton(
            count: filter.appliedCount,
            onPressed: () => context.pushNamed(AppRouteName.tasks.filter),
          ),
        ],
      ),
    );
  }

  Widget buildTasksView(List<Task> tasks, TaskFilter filter) {
    final visible = tasks.where(filter.matches).toList();

    return PaginatedListView<Task>(
      items: visible,

      /// Nothing matching means nothing to scroll, so no further page will ever
      /// load — show the footer text rather than a spinner that never resolves.
      hasMore: _hasMore && visible.isNotEmpty,
      noMoreItemsText: _footerText(tasks, visible),
      onRefresh: _onPullToRefreshTasks,
      updatePageNumber: (int? value) async =>
          ref.read(taskStateProvider.notifier).fetchNextPage(),
      buildItem: buildTask,
    );
  }

  String _footerText(List<Task> all, List<Task> visible) {
    if (visible.isNotEmpty) {
      return 'No more tasks';
    }

    return all.isEmpty ? 'No tasks yet' : 'No matching tasks';
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

  Future<void> _onPullToRefreshTasks() async {
    ref.read(taskStateProvider.notifier).refresh();
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
