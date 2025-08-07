// lib/widgets/task_item.dart
import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(bool?) onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Checkbox(value: task.isCompleted, onChanged: onToggle),
            const SizedBox(width: 12.0),
            Expanded(
              child: GestureDetector(
                onTap: onEdit, // Call the onEdit function when tapped
                child: Text(
                  task.title,
                  style: TextStyle(
                    color: onBackgroundColor,
                    fontSize: 16.0,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: onBackgroundColor.withOpacity(0.6)),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: onBackgroundColor.withOpacity(0.6),
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
