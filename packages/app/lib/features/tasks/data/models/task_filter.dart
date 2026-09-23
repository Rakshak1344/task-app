import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_filter.freezed.dart';

part 'task_filter.g.dart';

@freezed
sealed class TaskFilter with _$TaskFilter {
  const TaskFilter._();

  const factory TaskFilter({
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    TaskStatus? status,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    TaskPriority? priority,

    /// Search text is session-only — excluded from JSON so it never reaches
    /// storage, and so a relaunch never starts with a pre-filled search box.
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default('')
    String query,
  }) = _TaskFilter;

  factory TaskFilter.fromJson(Map<String, dynamic> json) =>
      _$TaskFilterFromJson(json);

  /// Only the stored fields count — the query is already visible in the search
  /// field sitting next to the badge.
  int get appliedCount =>
      (status == null ? 0 : 1) + (priority == null ? 0 : 1);

  bool get isEmpty => appliedCount == 0;

  /// Trimmed, or null when there is nothing to search for — keeps a blank or
  /// whitespace-only box out of the query string.
  String? get searchTerm {
    final trimmed = query.trim();

    return trimmed.isEmpty ? null : trimmed;
  }

  /// The parts the server cares about. Retyping the same word with different
  /// spacing is not a new request.
  bool sameRequestAs(TaskFilter other) =>
      status == other.status &&
      priority == other.priority &&
      searchTerm == other.searchTerm;

  bool matches(Task task) {
    if (status != null && task.status != status) {
      return false;
    }

    if (priority != null && task.priority != priority) {
      return false;
    }

    final needle = searchTerm?.toLowerCase();

    if (needle == null) {
      return true;
    }

    return task.title.toLowerCase().contains(needle) ||
        (task.description?.toLowerCase().contains(needle) ?? false);
  }
}
