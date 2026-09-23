import 'package:app/features/tasks/data/models/task_filter.dart';
import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:app/features/tasks/repositories/local_task_filter_repository.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_preferences.dart';

void main() {
  late ProviderContainer container;
  late LocalTaskFilterRepository repository;

  setUp(() {
    container = ProviderContainer(
      overrides: [preferenceProvider.overrideWithValue(FakePreferences())],
    );
    repository = container.read(localTaskFilterRepositoryProvider);
  });

  tearDown(() => container.dispose());

  test('reads as null when nothing has been stored', () {
    expect(repository.get(), isNull);
  });

  test('round-trips status and priority through storage', () async {
    await repository.save(
      const TaskFilter(
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
      ),
    );

    expect(
      repository.get(),
      const TaskFilter(
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
      ),
    );
  });

  test('keeps a cleared field null when the other one is set', () async {
    await repository.save(const TaskFilter(priority: TaskPriority.low));

    expect(repository.get()?.status, isNull);
    expect(repository.get()?.priority, TaskPriority.low);
  });

  test('delete removes the stored filter and the stream reports null', () async {
    await repository.save(const TaskFilter(status: TaskStatus.completed));

    final emissions = <TaskFilter?>[];
    final subscription = repository.watch().listen(emissions.add);
    await Future<void>.delayed(Duration.zero);

    await repository.delete();
    await Future<void>.delayed(Duration.zero);

    expect(repository.get(), isNull);
    expect(emissions.first, const TaskFilter(status: TaskStatus.completed));
    expect(emissions.last, isNull);

    await subscription.cancel();
  });
}
