import 'dart:convert';

import 'package:app/features/tasks/data/models/task_filter.dart';
import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:app/features/tasks/views/task_filter_page.dart';
import 'package:app/storage/const/preference_keys.dart';
import 'package:app/utils/keys.dart';
import 'package:core/arch/storage/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_preferences.dart';

Widget wrap(Preferences preferences) {
  return ProviderScope(
    overrides: [preferenceProvider.overrideWithValue(preferences)],
    child: const MaterialApp(home: TaskFilterPage()),
  );
}

TaskFilter? storedFilter(Preferences preferences) {
  final value = preferences.getValue<String?>(PreferenceKeys.taskFilter);
  if (value == null) {
    return null;
  }

  return TaskFilter.fromJson(jsonDecode(value) as Map<String, dynamic>);
}

void main() {
  group('TaskFilterPage', () {
    testWidgets('renders a chip per status and per priority', (tester) async {
      await tester.pumpWidget(wrap(FakePreferences()));
      await tester.pumpAndSettle();

      for (final status in TaskStatus.values) {
        expect(find.byKey(K.tasks.statusFilterChip(status)), findsOneWidget);
      }

      for (final priority in TaskPriority.values) {
        expect(
          find.byKey(K.tasks.priorityFilterChip(priority)),
          findsOneWidget,
        );
      }
    });

    testWidgets('selecting a chip stores the filter', (tester) async {
      final preferences = FakePreferences();
      await tester.pumpWidget(wrap(preferences));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(K.tasks.statusFilterChip(TaskStatus.inProgress)),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(K.tasks.priorityFilterChip(TaskPriority.high)),
      );
      await tester.pumpAndSettle();

      expect(
        storedFilter(preferences),
        const TaskFilter(
          status: TaskStatus.inProgress,
          priority: TaskPriority.high,
        ),
      );
    });

    testWidgets('tapping the selected chip again clears that field', (
      tester,
    ) async {
      final preferences = FakePreferences();
      await tester.pumpWidget(wrap(preferences));
      await tester.pumpAndSettle();

      final chip = find.byKey(K.tasks.statusFilterChip(TaskStatus.completed));

      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(storedFilter(preferences)?.status, TaskStatus.completed);

      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(storedFilter(preferences)?.status, isNull);
    });

    testWidgets('picking another chip replaces the current selection', (
      tester,
    ) async {
      final preferences = FakePreferences();
      await tester.pumpWidget(wrap(preferences));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(K.tasks.statusFilterChip(TaskStatus.pending)));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(K.tasks.statusFilterChip(TaskStatus.completed)),
      );
      await tester.pumpAndSettle();

      expect(storedFilter(preferences)?.status, TaskStatus.completed);
    });

    testWidgets('clear appears only once a filter is set and removes it', (
      tester,
    ) async {
      final preferences = FakePreferences();
      await tester.pumpWidget(wrap(preferences));
      await tester.pumpAndSettle();

      expect(find.byKey(K.tasks.clearFiltersButton), findsNothing);

      await tester.tap(
        find.byKey(K.tasks.priorityFilterChip(TaskPriority.low)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(K.tasks.clearFiltersButton), findsOneWidget);

      await tester.tap(find.byKey(K.tasks.clearFiltersButton));
      await tester.pumpAndSettle();

      expect(
        preferences.getValue<String?>(PreferenceKeys.taskFilter),
        isNull,
      );
      expect(find.byKey(K.tasks.clearFiltersButton), findsNothing);
    });
  });
}
