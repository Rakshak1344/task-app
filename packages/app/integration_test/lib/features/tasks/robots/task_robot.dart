import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:app/utils/keys.dart';
import 'package:core/test/page_robot.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class TaskRobot extends PageRobot {
  TaskRobot(super.app);

  Future<void> createTask({
    required String title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
  }) async {
    await openCreateForm();
    await enterTitle(title);

    if (description != null) {
      await enterDescription(description);
    }
    if (status != null) {
      await selectStatus(status);
    }
    if (priority != null) {
      await selectPriority(priority);
    }

    await submitForm();
  }

  Future<void> deleteTask(int taskId) async {
    await openTaskMenu(taskId);
    await tapDeleteOption();
    await confirmDelete();
  }

  Future<void> openTaskMenu(int taskId) async {
    await $.tap($(K.tasks.tileMoreButton(taskId)));
    await $.pumpAndSettle();
  }

  Future<void> tapEditOption() async {
    await $.tap($(K.tasks.tileEditOption));
    await $.pumpAndSettle();
  }

  Future<void> tapDeleteOption() async {
    await $.tap($(K.tasks.tileDeleteOption));
    await $.pumpAndSettle();
  }

  Future<void> confirmDelete() async {
    await $.tap($(K.tasks.deleteConfirmButton));
    await app.dismissSnackBar();
    await $.pumpAndSettle();
  }

  Future<void> cancelDelete() async {
    await $.tap($(K.tasks.deleteCancelButton));
    await $.pumpAndSettle();
  }

  Future<void> scrollToEnd() async {
    await $.tester.drag(find.byType(ListView), const Offset(0, -5000));
    await $.pumpAndSettle();
  }

  Future<void> openCreateForm() async {
    await $.tap($(K.tasks.createButton));
    await $.pumpAndSettle();
  }

  Future<void> enterTitle(String title) async {
    await $.enterText($(K.tasks.titleEntry), title);
  }

  Future<void> enterDescription(String description) async {
    await $.enterText($(K.tasks.descriptionEntry), description);
  }

  Future<void> selectStatus(TaskStatus status) async {
    await _selectDropdownItem(K.tasks.statusDropdown, status.label);
  }

  Future<void> selectPriority(TaskPriority priority) async {
    await _selectDropdownItem(K.tasks.priorityDropdown, priority.label);
  }

  Future<void> submitForm() async {
    await $.tap($(K.tasks.submitButton));
    await app.dismissSnackBar();
    await $.pumpAndSettle();
  }

  Future<void> goBack() async {
    await $.tester.pageBack();
    await $.pumpAndSettle();
  }

  Future<void> _selectDropdownItem(Key dropdown, String label) async {
    await $.tap($(dropdown));
    await $.pumpAndSettle();

    await $.tap($(label).last);
    await $.pumpAndSettle();
  }
}
