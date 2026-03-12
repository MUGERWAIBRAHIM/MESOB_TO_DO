// lib/features/tasks/presentation/providers/task_provider.dart
import 'package:flutter/foundation.dart';
import 'package:todo_app/core/network/api_service.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _selectedDate;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  TaskProvider() {
    _selectedDate = DateTime.now();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService().getTasks();
      _tasks = (response.data['data'] as List)
          .map((task) => Task.fromJson(task))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (e is DioException) {
        _error = "An internet connection is required";
      } else {
        _error = e.toString();
      }
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addTask(Task task) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await ApiService().createTask(task.toJson());
      final newTask = Task.fromJson(response.data['data']);
      
      _tasks = [..._tasks, newTask];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTask(Task updatedTask) async {
  try {
    if (updatedTask.id == null) {
      throw Exception('Cannot update task without an ID');
    }

    _isLoading = true;
    notifyListeners();

    final response = await ApiService()
        .updateTask(updatedTask.id!, updatedTask.toJson());

    final taskData = Task.fromJson(response.data['data']);

    _tasks = _tasks.map((task) =>
        task.id == updatedTask.id ? taskData : task
    ).toList();

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
    rethrow;
  }
}


  Future<void> deleteTask(String taskId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await ApiService().deleteTask(taskId);
      
      _tasks = _tasks.where((task) => task.id != taskId).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(String? taskId) async {
    if (taskId == null) {
      _error = "Task ID is null";
      notifyListeners();
      return;
    }
 
    try {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) return;

      final oldCompleted = _tasks[taskIndex].completed;

    // Optimistic UI update
      _tasks[taskIndex] =
          _tasks[taskIndex].copyWith(completed: !oldCompleted);
      notifyListeners();

    try {
      final response = await ApiService()
          .toggleTaskCompletion(taskId, !oldCompleted);

      final updatedTask = Task.fromJson(response.data['data']);

      _tasks[taskIndex] = updatedTask;
      notifyListeners();
    } catch (e) {
      // Revert UI on API failure
      _tasks[taskIndex] =
          _tasks[taskIndex].copyWith(completed: oldCompleted);
      notifyListeners();
      rethrow;
    }
    } catch (e) {
    _error = e.toString();
    notifyListeners();
    rethrow;
    }
  }
} 
