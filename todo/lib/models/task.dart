// lib/models/task.dart
// import 'dart:convert'; // For using jsonEncode and jsonDecode

// The Task data model
class Task {
  final String id;
  String title;
  bool isCompleted;

  Task({required this.id, required this.title, this.isCompleted = false});

  // Factory constructor to create a Task object from a JSON map
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
    );
  }

  // Method to convert a Task object to a JSON map
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isCompleted': isCompleted};
  }
}
