import 'package:app/features/tasks/views/widgets/task_filter_button.dart';
import 'package:app/features/tasks/views/widgets/task_search_field.dart';
import 'package:app/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('TaskSearchField', () {
    testWidgets('shows the value it was given', (tester) async {
      await tester.pumpWidget(
        wrap(TaskSearchField(value: 'report', onChanged: (_) {})),
      );

      expect(find.text('report'), findsOneWidget);
    });

    testWidgets('reports every keystroke', (tester) async {
      final changes = <String>[];

      await tester.pumpWidget(
        wrap(TaskSearchField(value: '', onChanged: changes.add)),
      );

      await tester.enterText(find.byKey(K.tasks.searchField), 'rep');
      await tester.pump();

      expect(changes, ['rep']);
    });

    testWidgets('the clear button appears only once there is text', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(TaskSearchField(value: '', onChanged: (_) {})),
      );

      expect(find.byKey(K.tasks.searchClearButton), findsNothing);

      await tester.enterText(find.byKey(K.tasks.searchField), 'rep');
      await tester.pump();

      expect(find.byKey(K.tasks.searchClearButton), findsOneWidget);
    });

    testWidgets('clearing empties the field and reports it', (tester) async {
      final changes = <String>[];

      await tester.pumpWidget(
        wrap(TaskSearchField(value: '', onChanged: changes.add)),
      );

      await tester.enterText(find.byKey(K.tasks.searchField), 'rep');
      await tester.pump();

      await tester.tap(find.byKey(K.tasks.searchClearButton));
      await tester.pump();

      expect(changes.last, '');
      expect(find.text('rep'), findsNothing);
      expect(find.byKey(K.tasks.searchClearButton), findsNothing);
    });
  });

  group('TaskFilterButton', () {
    testWidgets('renders no badge when nothing is applied', (tester) async {
      await tester.pumpWidget(
        wrap(TaskFilterButton(count: 0, onPressed: () {})),
      );

      expect(find.byKey(K.tasks.filterButton), findsOneWidget);
      expect(find.byKey(K.tasks.filterBadge), findsNothing);
    });

    testWidgets('badges the applied count', (tester) async {
      await tester.pumpWidget(
        wrap(TaskFilterButton(count: 2, onPressed: () {})),
      );

      expect(
        find.descendant(
          of: find.byKey(K.tasks.filterBadge),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('is still tappable behind the badge', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrap(TaskFilterButton(count: 2, onPressed: () => taps++)),
      );

      await tester.tap(find.byKey(K.tasks.filterButton));
      await tester.pump();

      expect(taps, 1);
    });
  });
}
