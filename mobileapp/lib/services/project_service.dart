import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/project_model.dart';

class ProjectService {
  static Future<List<ProjectModel>> getProjects() async {
    final data = await ApiClient.get(ApiEndpoints.projects);
    return (data as List).map((j) => ProjectModel.fromJson(j)).toList();
  }

  static Future<ProjectModel> getProject(int id) async {
    final data = await ApiClient.get(ApiEndpoints.project(id));
    return ProjectModel.fromJson(data);
  }

  static Future<ProjectModel> createProject(
    String name,
    String description,
  ) async {
    final data = await ApiClient.post(ApiEndpoints.projects, {
      'name': name,
      'description': description,
    });
    return ProjectModel.fromJson(data);
  }

  static Future<ProjectModel> updateProject(
    int id,
    String name,
    String description,
  ) async {
    final data = await ApiClient.patch(ApiEndpoints.project(id), {
      'name': name,
      'description': description,
    });
    return ProjectModel.fromJson(data);
  }

  static Future<void> deleteProject(int id) =>
      ApiClient.delete(ApiEndpoints.project(id));

  static Future<void> addMember(int projectId, int userId) async {
    await ApiClient.post('${ApiEndpoints.project(projectId)}add-member/', {
      'user_id': userId,
    });
  }
}
