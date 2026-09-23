import 'dart:convert';

import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:core/data/response.dart';
import 'package:flutter_test/flutter_test.dart';

const taskIndexBody = '''
{
  "data": [
    {
      "id": 23,
      "title": "Contract probe",
      "description": "shape check",
      "status": "in_progress",
      "priority": "high",
      "due_date": "2026-10-01T09:00:00+00:00",
      "created_at": "2026-09-11T15:34:10+00:00",
      "updated_at": "2026-09-11T15:34:10+00:00"
    }
  ],
  "links": {
    "first": "http://localhost/api/v1/tasks?page=1",
    "last": "http://localhost/api/v1/tasks?page=3",
    "prev": null,
    "next": "http://localhost/api/v1/tasks?page=2"
  },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 3,
    "links": [],
    "path": "http://localhost/api/v1/tasks",
    "per_page": 10,
    "to": 1,
    "total": 25
  }
}
''';

const taskStoreBody = '''
{
  "data": {
    "id": 23,
    "title": "Contract probe",
    "description": null,
    "status": "pending",
    "priority": "medium",
    "due_date": null,
    "created_at": "2026-09-11T15:34:10+00:00",
    "updated_at": "2026-09-11T15:34:10+00:00"
  }
}
''';

PagedResponse<Task> decodePage(String body) => PagedResponse<Task>.fromJson(
  json.decode(body) as Map<String, dynamic>,
  (json) => Task.fromJson(json as Map<String, dynamic>),
);

void main() {
  group('Task', () {
    test('parses the paginated index envelope', () {
      final response = decodePage(taskIndexBody);

      expect(response.data, hasLength(1));
      expect(response.meta.currentPage, 1);
      expect(response.meta.lastPage, 3);
      expect(response.meta.total, 25);
      expect(response.links.next, isNotNull);

      final task = response.data.single;
      expect(task.id, 23);
      expect(task.title, 'Contract probe');
      expect(task.status, TaskStatus.inProgress);
      expect(task.priority, TaskPriority.high);
      expect(task.dueDate, DateTime.utc(2026, 10, 1, 9));
      expect(task.user, isNull);
    });

    test('parses a single task and falls back to column defaults', () {
      final response = ObjectResponse<Task>.fromJson(
        json.decode(taskStoreBody) as Map<String, dynamic>,
        (json) => Task.fromJson(json as Map<String, dynamic>),
      );

      final task = response.data;
      expect(task.description, isNull);
      expect(task.status, TaskStatus.pending);
      expect(task.priority, TaskPriority.medium);
      expect(task.dueDate, isNull);
      expect(task.isOverdue, isFalse);
    });

    test('treats an unknown status or priority as the default', () {
      final task = Task.fromJson({
        'id': 1,
        'title': 'Unknown enums',
        'status': 'archived',
        'priority': 'critical',
      });

      expect(task.status, TaskStatus.pending);
      expect(task.priority, TaskPriority.medium);
    });

    test('flags an overdue task only while it is unfinished', () {
      final past = DateTime.now().subtract(const Duration(days: 1));

      final pending = Task(id: 1, title: 'Late', dueDate: past);
      expect(pending.isOverdue, isTrue);

      expect(pending.copyWith(status: TaskStatus.completed).isOverdue, isFalse);
    });
  });
}
