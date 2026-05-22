import 'package:flutter/foundation.dart';
import '../core/auth/token_storage.dart';
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
      final allProjects = await ProjectService.getProjects();
      final currentUserId = await TokenStorage.getUserId();

      if (currentUserId != null) {
        _projects = allProjects
            .where((p) => p.members.any((m) => m.id == currentUserId))
            .toList();
        debugPrint(
          '[PROJECT_PROVIDER] Pobrano ${allProjects.length} projektów, '
          'po filtrze (userId=$currentUserId): ${_projects.length}',
        );
      } else {
        _projects = [];
        debugPrint('[PROJECT_PROVIDER] Brak userId — lista projektów pusta');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('[PROJECT_PROVIDER] Błąd ładowania projektów: $_error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<ProjectModel?> createProject(String name, String description) async {
    try {
      final project = await ProjectService.createProject(name, description);
      debugPrint('[PROJECT_PROVIDER] Projekt utworzony id=${project.id}');
      return project;
    } catch (e) {
      _error = e.toString();
      debugPrint('[PROJECT_PROVIDER] Błąd tworzenia projektu: $_error');
      notifyListeners();
      return null;
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

  Future<bool> leaveProject(int id) async {
    try {
      final userId = await TokenStorage.getUserId();
      if (userId == null) {
        _error = 'Brak zalogowanego użytkownika';
        notifyListeners();
        return false;
      }
      await ProjectService.leaveProject(id, userId);
      _projects.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('[PROJECT_PROVIDER] leaveProject error: $_error');
      notifyListeners();
      return false;
    }
  }
}
