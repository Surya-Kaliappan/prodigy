import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

// -----------------------------------------------------------------------------
// Global Instances & Main App Entry Point
// -----------------------------------------------------------------------------

/// A global instance of the audio player, initialized once for the application.
final AudioPlayer audioPlayer = AudioPlayer();

/// A global instance of Uuid for generating unique task IDs.
final Uuid _uuid = const Uuid();

/// The main entry point for the Flutter application.
void main() {
  runApp(const TodoApp());
}

// -----------------------------------------------------------------------------
// App Widget and Theme Configuration
// -----------------------------------------------------------------------------

/// The root widget of the application, setting up the app's title and themes.
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
// Data Model for a single Task
// -----------------------------------------------------------------------------

/// Represents a single To-Do task with a unique ID, title, and completion status.
class Task {
  final String id;
  String title;
  bool isCompleted;

  Task({required this.id, required this.title, this.isCompleted = false});

  /// Factory constructor to create a Task object from a JSON map.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
    );
  }

  /// Method to convert a Task object to a JSON map for storage.
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isCompleted': isCompleted};
  }
}

// -----------------------------------------------------------------------------
// Data Storage Service using shared_preferences
// -----------------------------------------------------------------------------

/// A service class to handle saving and loading tasks from local storage.
class TaskStorage {
  static const _key = 'tasks';

  /// Saves a list of tasks to shared_preferences by encoding them to JSON strings.
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = tasks
        .map((task) => jsonEncode(task.toJson()))
        .toList();
    await prefs.setStringList(_key, jsonList);
  }

  /// Loads a list of tasks from shared_preferences by decoding JSON strings.
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_key);
    if (jsonList == null) {
      return [];
    }
    return jsonList
        .map((jsonString) => Task.fromJson(jsonDecode(jsonString)))
        .toList();
  }
}

// -----------------------------------------------------------------------------
// Main To-Do List Screen
// -----------------------------------------------------------------------------

/// The main screen of the application, responsible for displaying and managing tasks.
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TaskStorage _taskStorage = TaskStorage();
  List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  /// Loads tasks from local storage and updates the state.
  Future<void> _loadTasks() async {
    _tasks = await _taskStorage.loadTasks();
    setState(() {});
  }

  /// Adds a new task to the list and saves it to local storage.
  Future<void> _addTask(String title) async {
    if (title.isNotEmpty) {
      final newTask = Task(id: _uuid.v4(), title: title);
      setState(() {
        _tasks.add(newTask);
      });
      await _taskStorage.saveTasks(_tasks);
    }
  }

  /// Toggles the completion status of a task and saves the list.
  Future<void> _toggleTaskCompletion(String taskId) async {
    setState(() {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      task.isCompleted = !task.isCompleted;
    });
    await _taskStorage.saveTasks(_tasks);
  }

  /// Deletes a task from the list and saves the changes.
  Future<void> _deleteTask(String taskId) async {
    setState(() {
      _tasks.removeWhere((t) => t.id == taskId);
    });
    await _taskStorage.saveTasks(_tasks);
  }

  /// Shows a dialog for editing a task's title.
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

  @override
  Widget build(BuildContext context) {
    final Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;
    // final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My To-Do List',
          style: TextStyle(color: onBackgroundColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep, color: onBackgroundColor),
            onPressed: () {
              // Delete all completed tasks (will implement later)
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: onBackgroundColor),
            onPressed: () {
              // Filter tasks (will implement later)
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
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

// -----------------------------------------------------------------------------
// Custom Task Item Widget
// -----------------------------------------------------------------------------

/// A custom widget to display a single Task item with a checkbox, title, and edit/delete buttons.
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
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

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
            IconButton(
              icon: Icon(Icons.edit, color: onSurfaceColor.withOpacity(0.6)),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: onSurfaceColor.withOpacity(0.6)),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
