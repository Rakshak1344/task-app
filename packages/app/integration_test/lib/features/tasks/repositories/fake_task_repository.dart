import 'dart:math';

import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/repositories/network_task_repository.dart';
import 'package:core/data/models/models.dart';
import 'package:core/data/response.dart';
import 'package:dio/dio.dart';

import '../factories/task_factory.dart';

class FakeTaskRepository implements NetworkTaskRepository {
  FakeTaskRepository({this.totalTasks = 25}) : _error = null;

  FakeTaskRepository.failing(DioException error, {this.totalTasks = 25})
    : _error = error;

  final int totalTasks;
  final DioException? _error;

  @override
  Future<PagedResponse<Task>> index(int page, int perPage) async {
    _maybeThrow();

    final lastPage = max(1, (totalTasks / perPage).ceil());
    final offset = (page - 1) * perPage;
    final count = (totalTasks - offset).clamp(0, perPage);
    final tasks = count == 0 ? <Task>[] : TaskFixture.factory().makeMany(count);

    return PagedResponse(
      tasks,
      Meta(
        currentPage: page,
        lastPage: lastPage,
        perPage: perPage,
        path: '/tasks',
        from: count == 0 ? null : offset + 1,
        to: count == 0 ? null : offset + count,
        total: totalTasks,
      ),
      Links(
        first: _pageUrl(1, perPage),
        last: _pageUrl(lastPage, perPage),
        prev: page > 1 ? _pageUrl(page - 1, perPage) : null,
        next: page < lastPage ? _pageUrl(page + 1, perPage) : null,
      ),
    );
  }

  @override
  Future<ObjectResponse<Task>> show(int id) async {
    _maybeThrow();

    return ObjectResponse(TaskFixture.factory().withId(id).makeSingle());
  }

  @override
  Future<ObjectResponse<Task>> store(
    String title,
    String? description,
    String? status,
    String? priority,
    String? dueDate,
  ) async {
    _maybeThrow();

    return ObjectResponse(
      TaskFixture.factory()
          .fromRequest(
            title: title,
            description: description,
            status: status,
            priority: priority,
            dueDate: dueDate,
          )
          .makeSingle(),
    );
  }

  @override
  Future<ObjectResponse<Task>> update(
    int id,
    String title,
    String? description,
    String? status,
    String? priority,
    String? dueDate,
  ) async {
    _maybeThrow();

    return ObjectResponse(
      TaskFixture.factory()
          .fromRequest(
            id: id,
            title: title,
            description: description,
            status: status,
            priority: priority,
            dueDate: dueDate,
          )
          .makeSingle(),
    );
  }

  @override
  Future<void> destroy(int id) async => _maybeThrow();

  String _pageUrl(int page, int perPage) =>
      '/tasks?page=$page&per_page=$perPage';

  void _maybeThrow() {
    final error = _error;
    if (error != null) {
      throw error;
    }
  }
}
