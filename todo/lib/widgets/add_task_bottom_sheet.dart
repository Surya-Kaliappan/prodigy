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
    final Brightness brightness = Theme.of(context).brightness;
    final Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;

    // Dynamically set background colors based on theme
    final Color sheetBackgroundColor =
        brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white;
    final Color textFieldFillColor = brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade200;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: sheetBackgroundColor,
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
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Add a task',
                hintStyle: TextStyle(color: onBackgroundColor.withOpacity(0.5)),
                filled: true,
                fillColor: textFieldFillColor,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ElevatedButton.icon(
                //   onPressed: () {
                //     // Placeholder for reminder functionality
                //   },
                //   icon: Icon(Icons.alarm,
                //       color: Theme.of(context).colorScheme.primary, size: 18.0),
                //   label: Text('Add Reminder',
                //       style: TextStyle(
                //           color: Theme.of(context).colorScheme.primary,
                //           fontSize: 13.0)),
                //   style: ElevatedButton.styleFrom(
                //     padding:
                //         const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                //     backgroundColor: textFieldFillColor,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(50.0),
                //     ),
                //     elevation: 0,
                //   ),
                // ),
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
                  child: Row(
                    children: [
                      Icon(Icons.save_as_outlined,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('Save',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
