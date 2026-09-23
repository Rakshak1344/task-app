import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:app/features/tasks/repositories/local_task_repository.dart';
import 'package:app/features/tasks/repositories/network_task_repository.dart';
import 'package:app/features/tasks/views/states/task_filter_state.dart';
import 'package:app/features/tasks/views/states/task_state.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:core/data/models/models.dart';
import 'package:core/data/response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_preferences.dart';

class IndexCall {
  IndexCall(this.page, this.status, this.priority, this.search);

  final int page;
  final String? status;
  final String? priority;
  final String? search;

  @override
  String toString() =>
      'page=$page status=$status priority=$priority search=$search';
}

class _RecordingNetworkTaskRepository implements NetworkTaskRepository {
  final List<IndexCall> calls = [];

  @override
  Future<PagedResponse<Task>> index(
    int page,
    int perPage,
    String? status,
    String? priority,
    String? search,
  ) async {
    calls.add(IndexCall(page, status, priority, search));

    return PagedResponse(
      [Task(id: page, title: 'Task from page $page')],
      Meta(
        currentPage: page,
        lastPage: 5,
        perPage: perPage,
        path: '/tasks',
        total: 50,
      ),
      Links(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  late _RecordingNetworkTaskRepository network;
  late ProviderContainer container;
  late TaskState tasks;
  late TaskFilterState filter;

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  /// Long enough to clear the 400ms search debounce.
  Future<void> pastDebounce() =>
      Future<void>.delayed(const Duration(milliseconds: 550));

  setUp(() async {
    network = _RecordingNetworkTaskRepository();
    container = ProviderContainer(
      overrides: [
        preferenceProvider.overrideWithValue(FakePreferences()),
        networkTaskRepositoryProvider.overrideWithValue(network),
      ],
    );
    container.listen(taskStateProvider, (_, _) {});
    container.listen(taskFilterStateProvider, (_, _) {});

    tasks = container.read(taskStateProvider.notifier);
    filter = container.read(taskFilterStateProvider.notifier);

    await settle();
  });

  tearDown(() => container.dispose());

  test('the filter settling on startup does not fire a request', () async {
    await pastDebounce();

    expect(
      network.calls,
      isEmpty,
      reason: 'the list asks for page one itself — this would duplicate it',
    );
  });

  test('changing status reloads page one with the status param', () async {
    await tasks.fetchNextPage();
    await settle();

    await filter.updateStatus(TaskStatus.completed);
    await settle();

    expect(network.calls, hasLength(2));
    expect(network.calls.last.page, 1);
    expect(network.calls.last.status, 'completed');
  });

  test('priority goes over the wire as its value string', () async {
    await filter.updatePriority(TaskPriority.high);
    await settle();

    expect(network.calls.last.priority, 'high');
  });

  test('an unset filter sends no params at all', () async {
    await tasks.fetchNextPage();
    await settle();

    expect(network.calls.single.status, isNull);
    expect(network.calls.single.priority, isNull);
    expect(network.calls.single.search, isNull);
  });

  test('typing is debounced into a single request', () async {
    filter.updateQuery('r');
    filter.updateQuery('re');
    filter.updateQuery('rep');
    await settle();

    expect(network.calls, isEmpty, reason: 'still mid-typing');

    await pastDebounce();

    expect(network.calls, hasLength(1));
    expect(network.calls.single.search, 'rep');
    expect(network.calls.single.page, 1);
  });

  test('a whitespace-only search is neither sent nor requested', () async {
    filter.updateQuery('   ');
    await pastDebounce();

    expect(network.calls, isEmpty);
  });

  test('clearing the search back to empty reloads unfiltered', () async {
    filter.updateQuery('rep');
    await pastDebounce();

    filter.updateQuery('');
    await pastDebounce();

    expect(network.calls, hasLength(2));
    expect(network.calls.last.search, isNull);
  });

  test('the next page carries the active filter', () async {
    await filter.updateStatus(TaskStatus.completed);
    await settle();

    await tasks.fetchNextPage();
    await settle();

    expect(network.calls.last.page, 2, reason: 'the reload reset the cursor');
    expect(network.calls.last.status, 'completed');
  });

  test('reloading page one never emits an empty list in between', () async {
    await tasks.fetchNextPage();
    await settle();

    final emissions = <List<Task>>[];
    final subscription = container
        .read(localTaskRepositoryProvider)
        .watch()
        .listen(emissions.add);
    await settle();

    await tasks.refresh();
    await settle();

    expect(
      emissions.any((tasks) => tasks.isEmpty),
      isFalse,
      reason: 'an empty emission is the list flashing blank on every reload',
    );

    await subscription.cancel();
  });

  test('refresh goes back to page one', () async {
    await tasks.fetchNextPage();
    await tasks.fetchNextPage();
    await settle();

    expect(network.calls.last.page, 2);

    await tasks.refresh();
    await settle();

    expect(network.calls.last.page, 1);
  });
}
