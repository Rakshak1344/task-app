import 'package:app/utils/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../../config/task_test_app_config.dart';
import '../repositories/fake_task_repository.dart';
import '../robots/task_robot.dart';

TaskTestApp taskListApp({int totalTasks = 25}) =>
    TaskTestApp(taskRepository: FakeTaskRepository(totalTasks: totalTasks));

void main() {
  patrolTest("An empty list shows the no tasks message", ($) async {
    // Arrange
    var app = taskListApp(totalTasks: 0);
    await app.setupLoggedIn();
    await app.init($);

    // Assert
    expect(app.getTasks(), isEmpty);
    expect($('No tasks yet'), findsOneWidget);
    expect($('No more tasks'), findsNothing);
  });

  patrolTest("The end of a loaded list shows the no more tasks message", (
    $,
  ) async {
    // Arrange
    var app = taskListApp(totalTasks: 5);
    await app.setupLoggedIn();
    await app.init($);

    var taskRobot = TaskRobot(app);

    expect(app.getTasks(), hasLength(5));

    // Act
    await taskRobot.scrollToEnd();

    // Assert
    expect($('No more tasks'), findsOneWidget);
    expect($('No tasks yet'), findsNothing);
  });

  patrolTest("A task card offers edit and delete", ($) async {
    // Arrange
    var app = taskListApp();
    await app.setupLoggedIn();
    await app.init($);

    var taskRobot = TaskRobot(app);
    var task = app.getTasks().first;

    // Act
    await taskRobot.openTaskMenu(task.id);

    // Assert
    expect($(K.tasks.tileEditOption), findsOneWidget);
    expect($(K.tasks.tileDeleteOption), findsOneWidget);
  });

  patrolTest("Deleting a task removes its card from the list", ($) async {
    // Arrange
    var app = taskListApp();
    await app.setupLoggedIn();
    await app.init($);

    var taskRobot = TaskRobot(app);
    var doomed = app.getTasks().first;
    var initialCount = app.getTasks().length;

    expect($(K.tasks.tile(doomed.id)), findsOneWidget);

    // Act
    await taskRobot.deleteTask(doomed.id);

    // Assert
    expect($(K.tasks.tile(doomed.id)), findsNothing);

    var remaining = app.getTasks();

    expect(remaining, hasLength(initialCount - 1));
    expect(remaining.where((task) => task.id == doomed.id), isEmpty);
  });

  patrolTest("Scrolling to the end loads the next page", ($) async {
    // Arrange
    var app = taskListApp();
    await app.setupLoggedIn();
    await app.init($);

    var taskRobot = TaskRobot(app);

    expect(app.getTasks(), hasLength(10));
    expect($('No more tasks'), findsNothing);

    // Act
    await taskRobot.scrollToEnd();

    // Assert
    expect(app.getTasks(), hasLength(20));

    await taskRobot.scrollToEnd();

    expect(app.getTasks(), hasLength(25));

    await taskRobot.scrollToEnd();

    expect($('No more tasks'), findsOneWidget);
  });
}
