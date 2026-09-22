import 'package:app/features/tasks/data/models/task.dart';
import 'package:app/features/tasks/data/models/task_priority.dart';
import 'package:app/features/tasks/data/models/task_status.dart';
import 'package:app/features/tasks/views/states/task_detail_state.dart';
import 'package:app/features/tasks/views/states/task_form_state.dart';
import 'package:app/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskFormPage extends ConsumerStatefulWidget {
  const TaskFormPage({super.key, this.taskId});

  final int? taskId;

  bool get isEditing => taskId != null;

  @override
  ConsumerState createState() => _TaskFormPageState();
}

class _TaskFormPageState extends ConsumerState<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskStatus _status = TaskStatus.pending;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;

  bool _prefilled = false;

  @override
  void initState() {
    super.initState();

    final taskId = widget.taskId;
    if (taskId != null) {
      Future.microtask(
        () => ref.read(taskDetailStateProvider(taskId).notifier).fetchTask(),
      );
    }
  }

  void listenTaskDetail() {
    final taskId = widget.taskId;
    if (taskId == null) {
      return;
    }

    ref.listen(taskDetailStateProvider(taskId), (previous, next) {
      final task = next.value;
      if (task == null || _prefilled) {
        return;
      }

      setState(() {
        _prefilled = true;
        _applyTask(task);
      });
    });
  }

  void _applyTask(Task task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _status = task.status;
    _priority = task.priority;
    _dueDate = task.dueDate?.toLocal();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initial = _dueDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _dueDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time?.hour ?? 0,
        time?.minute ?? 0,
      );
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final task = await ref
        .read(taskFormStateProvider.notifier)
        .save(
          id: widget.taskId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _status,
          priority: _priority,
          dueDate: _dueDate,
        );

    if (!mounted) {
      return;
    }

    if (task == null) {
      final error = ref.read(taskFormStateProvider).error;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              "Failed to save task.\n$error",
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
            duration: const Duration(seconds: 8),
          ),
        );
      return;
    }

    Navigator.of(context).pop();
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) {
      return 'Title is required';
    }
    if (title.length > 255) {
      return 'Title must be 255 characters or fewer';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    listenTaskDetail();

    final isSaving = ref.watch(taskFormStateProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit task' : 'New task')),
      body: SafeArea(child: _buildBody(isSaving)),
    );
  }

  Widget _buildBody(bool isSaving) {
    final taskId = widget.taskId;

    if (taskId != null && !_prefilled) {
      final detail = ref.watch(taskDetailStateProvider(taskId));
      final error = detail.error;

      if (detail.hasError && error != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Failed to load task.\n$error'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref
                      .read(taskDetailStateProvider(taskId).notifier)
                      .fetchTask(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: K.tasks.titleEntry,
                controller: _titleController,
                enabled: !isSaving,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: _validateTitle,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: K.tasks.descriptionEntry,
                controller: _descriptionController,
                enabled: !isSaving,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskStatus>(
                key: K.tasks.statusDropdown,
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: TaskStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
                onChanged: isSaving
                    ? null
                    : (value) => setState(() => _status = value ?? _status),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                key: K.tasks.priorityDropdown,
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values
                    .map(
                      (priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority.label),
                      ),
                    )
                    .toList(),
                onChanged: isSaving
                    ? null
                    : (value) => setState(() => _priority = value ?? _priority),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Due date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dueDate == null
                            ? 'Not set'
                            : _dueDate!.toLocal().toString().split('.').first,
                      ),
                    ),
                    if (_dueDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: isSaving
                            ? null
                            : () => setState(() => _dueDate = null),
                      ),
                    IconButton(
                      icon: const Icon(Icons.event_outlined),
                      onPressed: isSaving ? null : _pickDueDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Visibility(
                visible: isSaving,
                replacement: FilledButton(
                  key: K.tasks.submitButton,
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.isEditing ? 'Save changes' : 'Create task',
                  ),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
