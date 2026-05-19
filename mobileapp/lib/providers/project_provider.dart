import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  List<ProjectModel> _projects = [];
  bool _loading = false;
  String? _error;

  List<ProjectModel> get projects => _projects;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadProjects() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _projects = await ProjectService.getProjects();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createProject(String name, String description) async {
    try {
      final project = await ProjectService.createProject(name, description);
      _projects.add(project);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProject(int id, String name, String description) async {
    try {
      final updated = await ProjectService.updateProject(id, name, description);
      final idx = _projects.indexWhere((p) => p.id == id);
      if (idx >= 0) _projects[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProject(int id) async {
    try {
      await ProjectService.deleteProject(id);
      _projects.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
