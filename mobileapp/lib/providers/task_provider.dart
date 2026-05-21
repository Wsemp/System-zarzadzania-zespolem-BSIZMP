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

  Future<void> loadTasks({int? projectId, int? assignedTo}) async {
    _loading = true;
    _currentProjectId = projectId;
    _error = null;
    notifyListeners();
    try {
      _tasks = await TaskService.getTasks(
        projectId: projectId,
        assignedTo: assignedTo,
      );
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
    TaskPriority priority = TaskPriority.medium,
    TaskArea? area,
    bool anonymousReporter = false,
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
        priority: priority,
        area: area,
        anonymousReporter: anonymousReporter,
        assignedTo: assignedTo,
        projectId: effectiveProjectId,
        dueDate: dueDate,
        tagIds: tagIds,
      );
      // Preserve local fields that backend doesn't store yet
      _tasks.add(task.copyWith(priority: priority, area: area));
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
      if (idx >= 0) {
        // Preserve local fields on status-only update
        _tasks[idx] = updated.copyWith(
          priority: _tasks[idx].priority,
          area: _tasks[idx].area,
        );
      }
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
    TaskPriority? priority,
    TaskArea? area,
    bool? anonymousReporter,
    int? assignedTo,
    String? dueDate,
    bool clearAssignee = false,
    bool clearDueDate = false,
    bool clearArea = false,
  }) async {
    _error = null;
    try {
      // priority/area/anonymous_reporter zarządzane lokalnie —
      // backend ich nie obsługuje (brak migracji)
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
      if (idx >= 0) {
        // Preserve local fields that backend doesn't return yet
        _tasks[idx] = updated.copyWith(
          priority: priority ?? _tasks[idx].priority,
          area: clearArea ? null : (area ?? _tasks[idx].area),
        );
      }
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
