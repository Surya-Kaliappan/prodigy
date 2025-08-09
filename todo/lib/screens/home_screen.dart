import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_storage.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../widgets/task_item.dart';
import 'package:uuid/uuid.dart';
import 'search_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _tasks = await _taskStorage.loadTasks();
    setState(() {});
  }

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

  @override
  Widget build(BuildContext context) {
    final Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;
    final List<Task> uncompletedTasks =
        _tasks.where((t) => !t.isCompleted).toList();
    final List<Task> completedTasks =
        _tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: onBackgroundColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings, color: onBackgroundColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 32,
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
              child: SlidableAutoCloseBehavior(
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
                    ...uncompletedTasks.map((task) {
                      return Slidable(
                        key: Key(task.id),
                        endActionPane: ActionPane(
                          motion: const StretchMotion(),
                          extentRatio: 0.2,
                          children: [
                            SlidableAction(
                              onPressed: (context) => _deleteTask(task.id),
                              backgroundColor:
                                  const Color.fromARGB(0, 254, 73, 73),
                              foregroundColor: const Color(0xFFFE4A49),
                              icon: Icons.delete,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ],
                        ),
                        child: TaskItem(
                          task: task,
                          onToggle: (value) => _toggleTaskCompletion(task.id),
                          onEdit: () => _showEditTaskBottomSheet(task),
                          onDelete: () => _deleteTask(task.id),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isCompletedExpanded = !_isCompletedExpanded;
                        });
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
                          children: completedTasks.map((task) {
                            return Slidable(
                              key: Key(task.id),
                              // This section is now updated to match the one above
                              endActionPane: ActionPane(
                                motion: const StretchMotion(),
                                extentRatio: 0.2,
                                children: [
                                  SlidableAction(
                                    onPressed: (context) =>
                                        _deleteTask(task.id),
                                    backgroundColor:
                                        const Color.fromARGB(0, 254, 73, 73),
                                    foregroundColor: const Color(0xFFFE4A49),
                                    icon: Icons.delete,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ],
                              ),
                              child: TaskItem(
                                task: task,
                                onToggle: (value) =>
                                    _toggleTaskCompletion(task.id),
                                onEdit: () => _showEditTaskBottomSheet(task),
                                onDelete: () => _deleteTask(task.id),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
