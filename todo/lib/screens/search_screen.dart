import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';
import '../services/task_storage.dart';
import '../widgets/add_task_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  final List<Task> tasks;

  const SearchScreen({super.key, required this.tasks});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Task> _filteredTasks = [];
  final TaskStorage _taskStorage = TaskStorage();

  @override
  void initState() {
    super.initState();
    _filteredTasks = [];
  }

  void _filterTasks(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredTasks = [];
      });
    } else {
      setState(() {
        _filteredTasks = widget.tasks
            .where((task) =>
                task.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _toggleTaskCompletion(String taskId) {
    setState(() {
      final task = widget.tasks.firstWhere((t) => t.id == taskId);
      task.isCompleted = !task.isCompleted;
      _filteredTasks = widget.tasks
          .where((t) => t.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
      _taskStorage.saveTasks(widget.tasks);
    });
  }

  void _deleteTask(String taskId) {
    setState(() {
      widget.tasks.removeWhere((t) => t.id == taskId);
      _filteredTasks = widget.tasks
          .where((t) => t.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
      _taskStorage.saveTasks(widget.tasks);
    });
  }

  void _showEditTaskBottomSheet(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddTaskBottomSheet(
          isEditMode: true,
          initialTitle: task.title,
          onAddTask: (String newTitle) {}, // Not used in edit mode
          onSave: (String newTitle) {
            setState(() {
              task.title = newTitle;
              _filteredTasks = widget.tasks
                  .where((t) => t.title
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()))
                  .toList();
            });
            _taskStorage.saveTasks(widget.tasks);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: onBackgroundColor),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Hero(
                      tag: 'search-hero',
                      child: Material(
                        color: Colors.transparent,
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: _filterTasks,
                          decoration: InputDecoration(
                            hintText: 'Search tasks...',
                            hintStyle: TextStyle(
                                color: onBackgroundColor.withOpacity(0.5)),
                            border: InputBorder.none,
                          ),
                          style:
                              TextStyle(color: onBackgroundColor, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = _filteredTasks[index];
                    return TaskItem(
                      task: task,
                      onToggle: (value) => _toggleTaskCompletion(task.id),
                      onEdit: () => _showEditTaskBottomSheet(task),
                      onDelete: () => _deleteTask(task.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
