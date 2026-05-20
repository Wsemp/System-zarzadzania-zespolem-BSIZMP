import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/task_model.dart';

class TaskService {
  static Future<List<TaskModel>> getTasks({int? projectId}) async {
    final path = projectId != null
        ? '${ApiEndpoints.tasks}?project=$projectId'
        : ApiEndpoints.tasks;

    final data = await ApiClient.get(path);
    final all = (data as List).map((j) => TaskModel.fromJson(j)).toList();

    debugPrint(
      '[TASK] getTasks – pobranych: ${all.length}, projectId: $projectId',
    );
    all.forEach((t) => debugPrint('  task#${t.id} project=${t.project}'));

    if (projectId != null) {
      final filtered = all.where((t) => t.project == projectId).toList();
      debugPrint('[TASK] po filtrze projekt=$projectId: ${filtered.length}');
      return filtered;
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
    final body = <String, dynamic>{
      'title': title,
      'description': description,
      'status': status.value,
      if (assignedTo != null) 'assigned_to': assignedTo,
      // Backend używa HyperlinkedRelatedField – wymaga pełnego URL
      if (projectId != null) 'project': ApiEndpoints.projectUrl(projectId),
      // Backend wymaga tag_ids zawsze (nawet pusta lista)
      'tag_ids': tagIds ?? [],
      if (dueDate != null) 'due_date': dueDate,
    };

    debugPrint('[TASK] POST ${ApiEndpoints.tasks}');
    debugPrint('[TASK] body: ${jsonEncode(body)}');

    final data = await ApiClient.post(ApiEndpoints.tasks, body);
    return TaskModel.fromJson(data);
  }

  static Future<TaskModel> updateTask(
    int id,
    Map<String, dynamic> fields,
  ) async {
    final body = Map<String, dynamic>.from(fields)
      ..removeWhere((_, v) => v == null);

    debugPrint('[TASK] PATCH ${ApiEndpoints.task(id)}');
    debugPrint('[TASK] body: ${jsonEncode(body)}');

    final data = await ApiClient.patch(ApiEndpoints.task(id), body);
    return TaskModel.fromJson(data);
  }

  static Future<void> deleteTask(int id) =>
      ApiClient.delete(ApiEndpoints.task(id));

  static Future<TaskModel> updateStatus(int id, TaskStatus status) =>
      updateTask(id, {'status': status.value});
}
