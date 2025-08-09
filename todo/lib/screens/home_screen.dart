// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/task.dart';
import '../services/task_storage.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../widgets/task_item.dart';
import 'package:uuid/uuid.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskStorage _taskStorage = TaskStorage();
  List<Task> _tasks = [];
  final Uuid _uuid = const Uuid();
  bool _isCompletedExpanded = true;

  // New state variables for selection mode
  bool _isSelectionMode = false;
  final Set<String> _selectedTaskIds = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _tasks = await _taskStorage.loadTasks();
    if (mounted) {
      setState(() {});
    }
  }

  // --- Selection Mode Logic ---

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedTaskIds.clear();
    });
  }

  void _onTaskTap(Task task) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedTaskIds.contains(task.id)) {
          _selectedTaskIds.remove(task.id);
        } else {
          _selectedTaskIds.add(task.id);
        }
        // If no items are selected, exit selection mode
        if (_selectedTaskIds.isEmpty) {
          _isSelectionMode = false;
        }
      });
    } else {
      // Default behavior: open edit sheet
      _showEditTaskBottomSheet(task);
    }
  }

  void _onTaskLongPress(Task task) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedTaskIds.add(task.id);
      });
    }
  }

  Future<void> _deleteSelectedTasks() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Tasks?'),
          content: Text(
              'Are you sure you want to delete ${_selectedTaskIds.length} selected tasks? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                setState(() {
                  _tasks.removeWhere(
                      (task) => _selectedTaskIds.contains(task.id));
                  _isSelectionMode = false;
                  _selectedTaskIds.clear();
                });
                await _taskStorage.saveTasks(_tasks);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- Original Task Logic ---

  Future<void> _addTask(String title) async {
    if (title.trim().isNotEmpty) {
      final newTask = Task(id: _uuid.v4(), title: title.trim());
      setState(() {
        _tasks.add(newTask);
      });
      await _taskStorage.saveTasks(_tasks);
    }
  }

  Future<void> _toggleTaskCompletion(String taskId) async {
    setState(() {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      task.isCompleted = !task.isCompleted;
    });
    await _taskStorage.saveTasks(_tasks);
  }

  Future<void> _deleteTask(String taskId) async {
    setState(() {
      _tasks.removeWhere((t) => t.id == taskId);
    });
    await _taskStorage.saveTasks(_tasks);
  }

  void _showEditTaskBottomSheet(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddTaskBottomSheet(
          isEditMode: true,
          initialTitle: task.title,
          onAddTask: (String newTitle) {},
          onSave: (String newTitle) {
            setState(() {
              task.title = newTitle;
            });
            _taskStorage.saveTasks(_tasks);
          },
        );
      },
    );
  }

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddTaskBottomSheet(onAddTask: _addTask);
      },
    );
  }

  // --- Build Method and App Bars ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _isSelectionMode ? _buildSelectionAppBar() : _buildDefaultAppBar(),
      body: _buildTaskList(),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: _showAddTaskBottomSheet,
              child: const Icon(Icons.add),
            ),
    );
  }

  AppBar _buildDefaultAppBar() {
    // final Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 20,
      // actions: [
      //   IconButton(
      //     icon: Icon(Icons.filter_list, color: onBackgroundColor),
      //     onPressed: () {},
      //   ),
      //   IconButton(
      //     icon: Icon(Icons.settings, color: onBackgroundColor),
      //     onPressed: () {},
      //   ),
      // ],
    );
  }

  AppBar _buildSelectionAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _toggleSelectionMode,
      ),
      title: Text('${_selectedTaskIds.length} selected'),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _selectedTaskIds.isNotEmpty ? _deleteSelectedTasks : null,
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    final Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;
    final List<Task> uncompletedTasks =
        _tasks.where((t) => !t.isCompleted).toList();
    final List<Task> completedTasks =
        _tasks.where((t) => t.isCompleted).toList();

    // Helper to build a single task item with gestures
    Widget buildTaskItem(Task task) {
      final bool isSelected = _selectedTaskIds.contains(task.id);
      return GestureDetector(
        onTap: () => _onTaskTap(task),
        onLongPress: () => _onTaskLongPress(task),
        child: AbsorbPointer(
          absorbing: _isSelectionMode,
          child: Slidable(
            key: Key(task.id),
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.2,
              children: [
                SlidableAction(
                  onPressed: (context) => _deleteTask(task.id),
                  backgroundColor: const Color.fromARGB(0, 254, 73, 73),
                  foregroundColor: const Color(0xFFFE4A49),
                  icon: Icons.delete,
                  borderRadius: BorderRadius.circular(50),
                ),
              ],
            ),
            child: TaskItem(
              task: task,
              isSelected: isSelected, // Pass selection state
              onToggle: (value) => _toggleTaskCompletion(task.id),
              onEdit: () => _showEditTaskBottomSheet(task),
              onDelete: () => _deleteTask(task.id),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!_isSelectionMode)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: onBackgroundColor,
                  ),
                ),
                Hero(
                  tag: 'search-hero',
                  child: IconButton(
                    icon:
                        Icon(Icons.search, size: 30, color: onBackgroundColor),
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                            builder: (context) => SearchScreen(tasks: _tasks),
                          ))
                          .then((value) => _loadTasks());
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                Text(
                  'To Be Completed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: onBackgroundColor.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 10),
                ...uncompletedTasks.map((task) => buildTaskItem(task)).toList(),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Disable expand/collapse in selection mode
                    if (!_isSelectionMode) {
                      setState(() {
                        _isCompletedExpanded = !_isCompletedExpanded;
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: onBackgroundColor.withOpacity(0.5),
                        ),
                      ),
                      Icon(
                          _isCompletedExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: onBackgroundColor),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  child: SizedBox(
                    height: _isCompletedExpanded ? null : 0,
                    child: Column(
                      children: completedTasks
                          .map((task) => buildTaskItem(task))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
