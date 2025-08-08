// import 'dart:convert';

/// Represents a single To-Do task with a unique ID, title, and completion status.
class Task {
  final String id;
  String title;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

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
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}
