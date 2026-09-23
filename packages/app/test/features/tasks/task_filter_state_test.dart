import 'package:app/features/tasks/data/models/task_filter.dart';
import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:app/features/tasks/views/states/task_filter_state.dart';
import 'package:app/storage/const/preference_keys.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_preferences.dart';

void main() {
  late FakePreferences preferences;
  late ProviderContainer container;
  late TaskFilterState notifier;

  /// Lets the storage stream deliver before assertions read the state.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  setUp(() async {
    preferences = FakePreferences();
    container = ProviderContainer(
      overrides: [preferenceProvider.overrideWithValue(preferences)],
    );
    container.listen(taskFilterStateProvider, (_, _) {});
    notifier = container.read(taskFilterStateProvider.notifier);

    await settle();
  });

  tearDown(() => container.dispose());

  TaskFilter current() => container.read(taskFilterStateProvider).value!;

  String? storedJson() =>
      preferences.getValue<String?>(PreferenceKeys.taskFilter);

  test('starts empty', () {
    expect(current(), const TaskFilter());
  });

  test('updateQuery lands on the state', () {
    notifier.updateQuery('report');

    expect(current().query, 'report');
  });

  test('the query survives a filter change coming back from storage', () async {
    notifier.updateQuery('report');

    await notifier.updateStatus(TaskStatus.completed);
    await settle();

    expect(current().status, TaskStatus.completed);
    expect(current().query, 'report', reason: 'storage must not wipe it');
  });

  test('the query is never written to storage', () async {
    notifier.updateQuery('report');

    await notifier.updatePriority(TaskPriority.high);
    await settle();

    expect(storedJson(), isNot(contains('report')));
    expect(storedJson(), isNot(contains('query')));
  });

  test('clear wipes the stored filter but leaves the search text', () async {
    notifier.updateQuery('report');
    await notifier.updateStatus(TaskStatus.completed);
    await settle();

    await notifier.clear();
    await settle();

    expect(storedJson(), isNull);
    expect(current().status, isNull);
    expect(current().query, 'report');
  });
}
