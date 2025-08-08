import 'package:flutter/material.dart';

class AddTaskDialog extends StatelessWidget {
  final TextEditingController taskController;
  final Function(String) onAddTask;

  const AddTaskDialog({
    super.key,
    required this.taskController,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text("Add New Task"),
      content: TextField(
        controller: taskController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Add a task',
          hintStyle: TextStyle(color: onBackgroundColor.withOpacity(0.5)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: onAddTask,
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            taskController.clear();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Add"),
          onPressed: () {
            if (taskController.text.isNotEmpty) {
              onAddTask(taskController.text);
            }
          },
        ),
      ],
    );
  }
}
