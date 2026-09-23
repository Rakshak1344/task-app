import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/data/models/task_filter.dart';
import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:flutter_test/flutter_test.dart';

Task task({
  int id = 1,
  String title = 'Write the report',
  String? description = 'Due before the review',
  TaskStatus status = TaskStatus.pending,
  TaskPriority priority = TaskPriority.medium,
}) {
  return Task(
    id: id,
    title: title,
    description: description,
    status: status,
    priority: priority,
  );
}

void main() {
  group('appliedCount', () {
    test('counts only the stored fields', () {
      expect(const TaskFilter().appliedCount, 0);
      expect(const TaskFilter(status: TaskStatus.pending).appliedCount, 1);
      expect(
        const TaskFilter(
          status: TaskStatus.pending,
          priority: TaskPriority.high,
        ).appliedCount,
        2,
      );
    });

    test('ignores the query, which is visible in the search field', () {
      const filter = TaskFilter(query: 'report');

      expect(filter.appliedCount, 0);
      expect(filter.isEmpty, isTrue);
    });
  });

  group('searchTerm', () {
    test('is null when there is nothing to search for', () {
      expect(const TaskFilter().searchTerm, isNull);
      expect(const TaskFilter(query: '').searchTerm, isNull);
      expect(const TaskFilter(query: '   ').searchTerm, isNull);
    });

    test('is trimmed, so the query string never carries padding', () {
      expect(const TaskFilter(query: '  report  ').searchTerm, 'report');
    });
  });

  group('sameRequestAs', () {
    test('a whitespace-only edit is not a new request', () {
      expect(
        const TaskFilter(query: 'report').sameRequestAs(
          const TaskFilter(query: '  report '),
        ),
        isTrue,
      );
    });

    test('an empty box and a blank box are the same request', () {
      expect(
        const TaskFilter().sameRequestAs(const TaskFilter(query: '  ')),
        isTrue,
      );
    });

    test('status, priority and the search term each count', () {
      const base = TaskFilter();

      expect(
        base.sameRequestAs(const TaskFilter(status: TaskStatus.completed)),
        isFalse,
      );
      expect(
        base.sameRequestAs(const TaskFilter(priority: TaskPriority.high)),
        isFalse,
      );
      expect(base.sameRequestAs(const TaskFilter(query: 'report')), isFalse);
    });
  });

  group('matches', () {
    test('an empty filter matches everything', () {
      expect(const TaskFilter().matches(task()), isTrue);
    });

    test('status narrows on its own', () {
      const filter = TaskFilter(status: TaskStatus.completed);

      expect(filter.matches(task(status: TaskStatus.completed)), isTrue);
      expect(filter.matches(task(status: TaskStatus.pending)), isFalse);
    });

    test('priority narrows on its own', () {
      const filter = TaskFilter(priority: TaskPriority.high);

      expect(filter.matches(task(priority: TaskPriority.high)), isTrue);
      expect(filter.matches(task(priority: TaskPriority.low)), isFalse);
    });

    test('query matches the title, case-insensitively', () {
      const filter = TaskFilter(query: 'REPORT');

      expect(filter.matches(task(title: 'Write the report')), isTrue);
      expect(filter.matches(task(title: 'Book a flight')), isFalse);
    });

    test('query matches the description too', () {
      const filter = TaskFilter(query: 'review');

      expect(
        filter.matches(
          task(title: 'Book a flight', description: 'Before the review'),
        ),
        isTrue,
      );
    });

    test('a task without a description is not a match by accident', () {
      const filter = TaskFilter(query: 'review');

      expect(
        filter.matches(task(title: 'Book a flight', description: null)),
        isFalse,
      );
    });

    test('a whitespace-only query constrains nothing', () {
      const filter = TaskFilter(query: '   ');

      expect(filter.matches(task(title: 'Book a flight')), isTrue);
    });

    test('status and query combine as AND', () {
      const filter = TaskFilter(
        status: TaskStatus.completed,
        query: 'report',
      );

      expect(
        filter.matches(task(title: 'Write the report', status: TaskStatus.completed)),
        isTrue,
      );

      /// Right title, wrong status.
      expect(
        filter.matches(task(title: 'Write the report', status: TaskStatus.pending)),
        isFalse,
      );

      /// Right status, wrong title.
      expect(
        filter.matches(task(title: 'Book a flight', status: TaskStatus.completed)),
        isFalse,
      );
    });
  });
}
