import 'package:app/utils/keys.dart';
import 'package:flutter/material.dart';

class TaskSearchField extends StatefulWidget {
  const TaskSearchField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;

  /// Emits on every keystroke, and `''` when the clear button is tapped.
  final ValueChanged<String> onChanged;

  @override
  State<TaskSearchField> createState() => _TaskSearchFieldState();
}

class _TaskSearchFieldState extends State<TaskSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(TaskSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// Only when the value changed from the outside — assigning the text the
    /// field already holds would move the caret to the end mid-typing.
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    /// Rebuilds so the clear button appears and disappears with the text.
    setState(() {});
    widget.onChanged(value);
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: K.tasks.searchField,
      controller: _controller,
      textInputAction: TextInputAction.search,
      onChanged: _onChanged,
      decoration: InputDecoration(
        hintText: 'Search by title',
        isDense: true,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                key: K.tasks.searchClearButton,
                icon: const Icon(Icons.close),
                tooltip: 'Clear search',
                onPressed: _clear,
              ),
      ),
    );
  }
}
