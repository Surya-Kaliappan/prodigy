import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

/// A service class to handle saving and loading tasks from local storage.
class TaskStorage {
  static const _key = 'tasks';

  /// Saves a list of tasks to shared_preferences by encoding them to JSON strings.
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList =
        tasks.map((task) => jsonEncode(task.toJson())).toList();
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
