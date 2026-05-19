import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/task_model.dart';

class TaskService {
  static Future<List<TaskModel>> getTasks({int? projectId}) async {
    // TODO: dodaj ?project=id gdy backend obsłuży filtrowanie po projekcie
    final data = await ApiClient.get(ApiEndpoints.tasks);
    final all = (data as List).map((j) => TaskModel.fromJson(j)).toList();
    if (projectId != null) {
      return all.where((t) => t.project == projectId).toList();
    }
    return all;
  }

  static Future<TaskModel> getTask(int id) async {
    final data = await ApiClient.get(ApiEndpoints.task(id));
    return TaskModel.fromJson(data);
  }

  static Future<TaskModel> createTask({
    required String title,
    required String description,
    required TaskStatus status,
    int? assignedTo,
    int? projectId,
    List<int>? tagIds,
    String? dueDate,
  }) async {
    final data = await ApiClient.post(ApiEndpoints.tasks, {
      'title': title,
      'description': description,
      'status': status.value,
      'assigned_to': assignedTo,
      'project': projectId,
      'tag_ids': tagIds ?? [],
      'due_date': dueDate,
    });
    return TaskModel.fromJson(data);
  }

  static Future<TaskModel> updateTask(
    int id,
    Map<String, dynamic> fields,
  ) async {
    final data = await ApiClient.patch(ApiEndpoints.task(id), fields);
    return TaskModel.fromJson(data);
  }

  static Future<void> deleteTask(int id) =>
      ApiClient.delete(ApiEndpoints.task(id));

  static Future<TaskModel> updateStatus(int id, TaskStatus status) =>
      updateTask(id, {'status': status.value});
}
