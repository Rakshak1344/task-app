import 'package:app/features/tasks/views/task_form_page.dart';
import 'package:app/navigation/app_route_name.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../../config/task_test_app_config.dart';
import '../consts/k_task.dart';
import '../repositories/fake_task_repository.dart';
import '../robots/task_robot.dart';

TaskTestApp emptyTaskListApp() =>
    TaskTestApp(taskRepository: FakeTaskRepository(totalTasks: 0));

void main() {
  patrolTest("Creating a task adds it to the list", ($) async {
    // Arrange
    var app = emptyTaskListApp();
    await app.setupLoggedIn();
    await app.init($);

    var taskRobot = TaskRobot(app);
    var taskListRoute = app.getRouteFor(AppRouteName.tasks.list);

    expect(app.getTasks(), isEmpty);

    // Act
    await taskRobot.createTask(
      title: KTask.title,
      description: KTask.description,
    );

    // Assert
    expect(app.getCurrentRoute(), taskListRoute);
    expect($(KTask.title), findsOneWidget);

    var tasks = app.getTasks();

    expect(tasks, hasLength(1));
    expect(tasks.first.title, KTask.title);
    expect(tasks.first.description, KTask.description);
  });

  patrolTest("A blank title is rejected", ($) async {
    // Arrange
    var app = emptyTaskListApp();
    await app.setupLoggedIn();
    await app.init($);

    var taskRobot = TaskRobot(app);
    var createRoute = app.getRouteFor(AppRouteName.tasks.create);

    await taskRobot.openCreateForm();
    expect(app.getCurrentRoute(), createRoute);

    // Act
    await taskRobot.submitForm();

    // Assert
    expect($('Title is required'), findsOneWidget);
    expect($(TaskFormPage), findsOneWidget);
    expect(app.getCurrentRoute(), createRoute);
    expect(app.getTasks(), isEmpty);
  });

  patrolTest("Status and priority carry through to the created task", ($) async {
    // Arrange
    var app = emptyTaskListApp();
    await app.setupLoggedIn();
    await app.init($);

    var taskRobot = TaskRobot(app);

    // Act
    await taskRobot.createTask(
      title: KTask.title,
      status: KTask.status,
      priority: KTask.priority,
    );

    // Assert
    var tasks = app.getTasks();

    expect(tasks, hasLength(1));
    expect(tasks.first.status, KTask.status);
    expect(tasks.first.priority, KTask.priority);

    expect($(KTask.status.label), findsOneWidget);
    expect($(KTask.priority.label), findsOneWidget);
  });

  patrolTest("Leaving the form without saving adds nothing", ($) async {
    // Arrange
    var app = emptyTaskListApp();
    await app.setupLoggedIn();
    await app.init($);

    var taskRobot = TaskRobot(app);
    var taskListRoute = app.getRouteFor(AppRouteName.tasks.list);

    await taskRobot.openCreateForm();
    await taskRobot.enterTitle(KTask.title);

    // Act
    await taskRobot.goBack();

    // Assert
    expect(app.getCurrentRoute(), taskListRoute);
    expect(app.getTasks(), isEmpty);
    expect($('No tasks yet'), findsOneWidget);
  });
}
