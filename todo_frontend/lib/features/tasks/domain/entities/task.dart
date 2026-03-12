// lib/features/tasks/domain/entities/task.dart
class Task {
  final String? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String startTime;
  final String endTime;
  final String category;
  final bool completed;

  const Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.startTime,
    required this.endTime,
    required this.category,
    this.completed = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? startTime,
    String? endTime,
    String? category,
    bool? completed,
}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      completed: completed ?? this.completed,
  );
}


  // In the Task class
factory Task.fromJson(Map<String, dynamic> json) {
  return Task(
    id: json['_id']?.toString(),
    title: json['title'],
    description: json['description'] ?? '',
    dueDate: DateTime.parse(json['dueDate']),
    startTime: json['startTime'],
    endTime: json['endTime'],
    category: json['category'],
    completed: json['completed'] ?? false,
  );
}


// Add toJson method for sending data to the server
Map<String, dynamic> toJson() {
  return {
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'startTime': startTime,
    'endTime': endTime,
    'category': category,
    'completed': completed,
  };
}
}