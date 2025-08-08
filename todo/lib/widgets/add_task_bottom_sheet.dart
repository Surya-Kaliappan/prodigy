import 'package:flutter/material.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Function(String) onAddTask;
  final Function(String)? onSave;
  final String? initialTitle;
  final bool isEditMode;

  const AddTaskBottomSheet({
    super.key,
    required this.onAddTask,
    this.onSave,
    this.initialTitle,
    this.isEditMode = false,
  });

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: onBackgroundColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  widget.isEditMode ? 'Edit Task' : 'New Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: onBackgroundColor,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null, // This allows the text to wrap to a new line
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Add a task',
                hintStyle: TextStyle(color: onBackgroundColor.withOpacity(0.5)),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surface, // Changed the background color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
                if (widget.isEditMode && widget.onSave != null) {
                  widget.onSave!(value);
                } else {
                  widget.onAddTask(value);
                }
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.alarm, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Add Reminder',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _controller.clear();
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface)),
                ),
                TextButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      if (widget.isEditMode && widget.onSave != null) {
                        widget.onSave!(_controller.text);
                      } else {
                        widget.onAddTask(_controller.text);
                      }
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('Save',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
