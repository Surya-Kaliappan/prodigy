import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatefulWidget {
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
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    final Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _showActions = !_showActions;
        });
      },
      onTap: () {
        if (_showActions) {
          setState(() {
            _showActions = false;
          });
        } else {
          widget.onToggle(!widget.task.isCompleted);
        }
      },
      child: Container(
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
              GestureDetector(
                onTap: () => widget.onToggle(!widget.task.isCompleted),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: widget.task.isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: widget.task.isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : onBackgroundColor.withOpacity(0.5),
                      width: 2,
                    ),
                    borderRadius:
                        BorderRadius.circular(12.0), // Makes the checkbox round
                  ),
                  child: widget.task.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  widget.task.title,
                  style: TextStyle(
                    color: onBackgroundColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold, // <--- BOLD FONT
                    decoration: widget.task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
              if (_showActions) ...[
                IconButton(
                  icon:
                      Icon(Icons.edit, color: onSurfaceColor.withOpacity(0.6)),
                  onPressed: widget.onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete,
                      color: onSurfaceColor.withOpacity(0.6)),
                  onPressed: widget.onDelete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
