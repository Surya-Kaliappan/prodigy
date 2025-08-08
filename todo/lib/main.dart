import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:audioplayers/audioplayers.dart';

import 'models/task.dart';
import 'services/task_storage.dart';
import 'widgets/task_item.dart';

// -----------------------------------------------------------------------------
// Global Instances & Main App Entry Point
// -----------------------------------------------------------------------------

final AudioPlayer audioPlayer = AudioPlayer();
final Uuid _uuid = const Uuid();
final TaskStorage _taskStorage = TaskStorage();

void main() {
  runApp(const TodoApp());
}

// -----------------------------------------------------------------------------
// App Widget and Theme Configuration
// -----------------------------------------------------------------------------

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My To-Do',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const TodoListScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// Main To-Do List Screen
// -----------------------------------------------------------------------------

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

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
      _taskController.clear();
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

  void _showEditTaskDialog(Task task) {
    _taskController.text = task.title;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: TextField(
            controller: _taskController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Edit task here"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                _taskController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  setState(() {
                    task.title = _taskController.text;
                  });
                  _taskStorage.saveTasks(_tasks);
                  _taskController.clear();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskSummary(BuildContext context) {
    final int totalTasks = _tasks.length;
    final int completedTasks = _tasks.where((task) => task.isCompleted).length;
    final Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: onBackgroundColor,
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Assigned: $totalTasks',
                  style: TextStyle(
                    fontSize: 16,
                    color: onBackgroundColor.withOpacity(0.7),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Completed: $completedTasks',
                  style: TextStyle(
                    fontSize: 16,
                    color: onBackgroundColor.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My To-Do List',
          style: TextStyle(color: onBackgroundColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        // <--- Main Column for the body
        children: <Widget>[
          _buildTaskSummary(context), // <--- The new task summary
          Expanded(
            child: _tasks.isEmpty
                ? Center(
                    child: Text(
                      'Your To-Do List will appear here!',
                      style: TextStyle(color: onBackgroundColor),
                    ),
                  )
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      // ... (Dismissible widget and TaskItem are here)
                      return Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _deleteTask(task.id);
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: TaskItem(
                          task: task,
                          onToggle: (value) => _toggleTaskCompletion(task.id),
                          onDelete: () => _deleteTask(task.id),
                          onEdit: () => _showEditTaskDialog(task),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'Add New Task...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _addTask(_taskController.text);
                    _taskController.clear();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onSubmitted: (value) {
                _addTask(value);
                _taskController.clear();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: null,
    );
  }
}
