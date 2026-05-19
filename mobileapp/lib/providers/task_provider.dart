import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _loading = false;
  String? _error;
  int? _currentProjectId;

  List<TaskModel> get tasks => _tasks;
  bool get loading => _loading;
  String? get error => _error;

  List<TaskModel> getByStatus(TaskStatus status) =>
      _tasks.where((t) => t.status == status).toList();

  Future<void> loadTasks({int? projectId}) async {
    _loading = true;
    _currentProjectId = projectId;
    _error = null;
    notifyListeners();
    try {
      _tasks = await TaskService.getTasks(projectId: projectId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createTask({
    required String title,
    required String description,
    required TaskStatus status,
    int? assignedTo,
    String? dueDate,
  }) async {
    try {
      final task = await TaskService.createTask(
        title: title,
        description: description,
        status: status,
        assignedTo: assignedTo,
        projectId: _currentProjectId,
        dueDate: dueDate,
      );
      _tasks.add(task);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(int id, TaskStatus status) async {
    try {
      final updated = await TaskService.updateStatus(id, status);
      final idx = _tasks.indexWhere((t) => t.id == id);
      if (idx >= 0) _tasks[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(int id, Map<String, dynamic> fields) async {
    try {
      final updated = await TaskService.updateTask(id, fields);
      final idx = _tasks.indexWhere((t) => t.id == id);
      if (idx >= 0) _tasks[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await TaskService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
