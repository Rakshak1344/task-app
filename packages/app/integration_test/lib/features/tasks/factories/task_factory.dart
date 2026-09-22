// ignore_for_file: library_private_types_in_public_api

import 'package:app/features/auth/data/models/user.dart';
import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:data_fixture_dart/data_fixture_dart.dart';

import '../../auth/factories/user_factory.dart';

extension TaskFixture on Task {
  static _TaskFixtureFactory factory() => _TaskFixtureFactory();
}

class _TaskFixtureFactory extends JsonFixtureFactory<Task> {
  static int _idSequence = 0;

  @override
  FixtureDefinition<Task> definition() => define((faker, [int index = 0]) {
    final now = DateTime.now();
    final createdAt = faker.date.dateTimeBetween(
      now.subtract(const Duration(days: 30)),
      now,
    );

    return Task(
      id: ++_idSequence,
      title: faker.lorem.sentence(),
      description: faker.lorem.sentences(2).join(' '),
      status: faker.randomGenerator.element(TaskStatus.values),
      priority: faker.randomGenerator.element(TaskPriority.values),
      dueDate: faker.date.dateTimeBetween(
        now,
        now.add(const Duration(days: 30)),
      ),
      user: UserFixture.factory().makeSingle(),
      createdAt: createdAt,
      updatedAt: faker.date.dateTimeBetween(createdAt, now),
    );
  });

  @override
  JsonFixtureDefinition<Task> jsonDefinition() =>
      defineJson((task, [int index = 0]) => task.toJson());

  JsonFixtureDefinition<Task> withId(int id) =>
      redefineJson((task, [int index = 0]) => task.copyWith(id: id));

  JsonFixtureDefinition<Task> withTitle(String title) =>
      redefineJson((task, [int index = 0]) => task.copyWith(title: title));

  JsonFixtureDefinition<Task> withStatus(TaskStatus status) =>
      redefineJson((task, [int index = 0]) => task.copyWith(status: status));

  JsonFixtureDefinition<Task> withPriority(TaskPriority priority) =>
      redefineJson(
        (task, [int index = 0]) => task.copyWith(priority: priority),
      );

  JsonFixtureDefinition<Task> withUser(User user) =>
      redefineJson((task, [int index = 0]) => task.copyWith(user: user));

  JsonFixtureDefinition<Task> pending() => withStatus(TaskStatus.pending);

  JsonFixtureDefinition<Task> completed() => withStatus(TaskStatus.completed);

  JsonFixtureDefinition<Task> overdue() => redefineJson(
    (task, [int index = 0]) => task.copyWith(
      status: TaskStatus.pending,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  );

  JsonFixtureDefinition<Task> fromRequest({
    int? id,
    required String title,
    String? description,
    String? status,
    String? priority,
    String? dueDate,
  }) => redefineJson(
    (task, [int index = 0]) => task.copyWith(
      id: id ?? task.id,
      title: title,
      description: description,
      status: _statusFrom(status) ?? task.status,
      priority: _priorityFrom(priority) ?? task.priority,
      dueDate: dueDate == null ? null : DateTime.parse(dueDate),
    ),
  );

  static TaskStatus? _statusFrom(String? value) => value == null
      ? null
      : TaskStatus.values.where((status) => status.value == value).firstOrNull;

  static TaskPriority? _priorityFrom(String? value) => value == null
      ? null
      : TaskPriority.values
            .where((priority) => priority.value == value)
            .firstOrNull;
}
