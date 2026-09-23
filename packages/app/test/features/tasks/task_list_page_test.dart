import 'dart:convert';

import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:app/features/tasks/repositories/network_task_repository.dart';
import 'package:app/features/tasks/views/task_list_page.dart';
import 'package:app/storage/const/preference_keys.dart';
import 'package:app/utils/keys.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:core/error/exceptions/no_more_data_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_preferences.dart';

/// The list asks for page 1 as soon as it mounts. Reporting "no more data"
/// keeps the test offline and settles the paging footer.
class _ExhaustedNetworkTaskRepository implements NetworkTaskRepository {
  @override
  Future<Never> index(
    int page,
    int perPage,
    String? status,
    String? priority,
    String? search,
  ) async => throw NoMoreDataException();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

const _report = Task(
  id: 1,
  title: 'Write the report',
  description: 'Due before the review',
  status: TaskStatus.pending,
);

const _flight = Task(
  id: 2,
  title: 'Book a flight',
  description: 'Window seat',
  status: TaskStatus.completed,
);

FakePreferences preferencesWith({String? filterJson}) {
  return FakePreferences({
    'tasks': jsonEncode([_report.toJson(), _flight.toJson()]),
    PreferenceKeys.taskFilter: ?filterJson,
  });
}

Widget wrap(Preferences preferences) {
  return ProviderScope(
    overrides: [
      preferenceProvider.overrideWithValue(preferences),
      networkTaskRepositoryProvider.overrideWithValue(
        _ExhaustedNetworkTaskRepository(),
      ),
    ],
    child: const MaterialApp(home: TaskListPage()),
  );
}

/// `pumpAndSettle` would hang on the paging spinner, so pump a fixed number of
/// frames instead.
Future<void> pumpList(WidgetTester tester) async {
  await tester.pumpWidget(wrap(preferencesWith()));
  for (var i = 0; i < 4; i++) {
    await tester.pump();
  }
}

void main() {
  group('TaskListPage', () {
    testWidgets('the old app-bar filter icon is gone', (tester) async {
      await pumpList(tester);

      expect(find.byIcon(Icons.filter), findsNothing);
      expect(find.byKey(K.tasks.searchField), findsOneWidget);
      expect(find.byKey(K.tasks.filterButton), findsOneWidget);
    });

    testWidgets('searching narrows the visible tasks', (tester) async {
      await pumpList(tester);

      expect(find.byKey(K.tasks.tile(_report.id)), findsOneWidget);
      expect(find.byKey(K.tasks.tile(_flight.id)), findsOneWidget);

      await tester.enterText(find.byKey(K.tasks.searchField), 'flight');
      await tester.pump();

      expect(find.byKey(K.tasks.tile(_report.id)), findsNothing);
      expect(find.byKey(K.tasks.tile(_flight.id)), findsOneWidget);
    });

    testWidgets('a search matching nothing says so', (tester) async {
      await pumpList(tester);

      await tester.enterText(find.byKey(K.tasks.searchField), 'zzz');
      await tester.pump();

      expect(find.text('No matching tasks'), findsOneWidget);
      expect(find.text('No tasks yet'), findsNothing);
    });

    testWidgets('a stored filter narrows the list and badges the button', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(preferencesWith(filterJson: '{"status":"completed"}')),
      );
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }

      expect(find.byKey(K.tasks.tile(_report.id)), findsNothing);
      expect(find.byKey(K.tasks.tile(_flight.id)), findsOneWidget);

      expect(
        find.descendant(
          of: find.byKey(K.tasks.filterBadge),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('no badge when no filter is stored', (tester) async {
      await pumpList(tester);

      expect(find.byKey(K.tasks.filterBadge), findsNothing);
    });
  });
}
