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
  int? get currentProjectId => _currentProjectId;

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

  /// [projectId] – bezpośrednie ID projektu z ekranu formularza.
  /// Fallback do [_currentProjectId] gdy nie podano (np. tworzenie poza kontekstem projektu).
  Future<bool> createTask({
    required String title,
    required String description,
    required TaskStatus status,
    int? assignedTo,
    int? projectId,
    String? dueDate,
    List<int>? tagIds,
  }) async {
    _error = null;
    final effectiveProjectId = projectId ?? _currentProjectId;
    try {
      final task = await TaskService.createTask(
        title: title,
        description: description,
        status: status,
        assignedTo: assignedTo,
        projectId: effectiveProjectId,
        dueDate: dueDate,
        tagIds: tagIds,
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
    _error = null;
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

  Future<bool> updateTask(
    int id, {
    String? title,
    String? description,
    TaskStatus? status,
    int? assignedTo,
    String? dueDate,
    bool clearAssignee = false,
    bool clearDueDate = false,
  }) async {
    _error = null;
    try {
      final fields = <String, dynamic>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (status != null) 'status': status.value,
        if (clearAssignee)
          'assigned_to': null
        else if (assignedTo != null)
          'assigned_to': assignedTo,
        if (clearDueDate)
          'due_date': null
        else if (dueDate != null)
          'due_date': dueDate,
      };
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
    _error = null;
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
