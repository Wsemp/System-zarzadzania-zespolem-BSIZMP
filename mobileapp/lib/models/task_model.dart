enum TaskStatus { todo, inProgress, done }

extension TaskStatusExt on TaskStatus {
  String get value {
    switch (this) {
      case TaskStatus.todo:
        return 'todo';
      case TaskStatus.inProgress:
        return 'In progress';
      case TaskStatus.done:
        return 'done';
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'Do wykonania';
      case TaskStatus.inProgress:
        return 'W trakcie';
      case TaskStatus.done:
        return 'Zakończone';
    }
  }

  static TaskStatus fromString(String? value) {
    switch (value) {
      case 'In progress':
      case 'in-progress':
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }
}

class TaskModel {
  final int id;
  final String title;
  final String description;
  final TaskStatus status;
  final int? assignedTo;
  final String? assignedToUsername;
  final int? project;
  final List<int> tagIds;
  final String? dueDate;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.assignedTo,
    this.assignedToUsername,
    this.project,
    required this.tagIds,
    this.dueDate,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final assignedRaw = json['assigned_to'];
    final projectRaw = json['project'];
    final tagsRaw = json['tag_ids'] ?? json['tags'] ?? const [];

    return TaskModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: TaskStatusExt.fromString(json['status'] as String?),
      assignedTo: _extractId(assignedRaw),
      assignedToUsername: assignedRaw is Map
          ? assignedRaw['username'] as String?
          : null,
      project: _extractId(projectRaw),
      tagIds: (tagsRaw as List)
          .map((e) => _extractId(e))
          .whereType<int>()
          .toList(),
      dueDate: json['due_date'] as String?,
    );
  }

  static int? _extractId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String && value.isNotEmpty) {
      final segments = value.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) return int.tryParse(segments.last);
    }
    if (value is Map) return value['id'] as int?;
    return null;
  }

  TaskModel copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    int? assignedTo,
    String? assignedToUsername,
    int? project,
    List<int>? tagIds,
    String? dueDate,
    bool clearAssignee = false,
    bool clearDueDate = false,
  }) => TaskModel(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    assignedTo: clearAssignee ? null : (assignedTo ?? this.assignedTo),
    assignedToUsername: clearAssignee
        ? null
        : (assignedToUsername ?? this.assignedToUsername),
    project: project ?? this.project,
    tagIds: tagIds ?? this.tagIds,
    dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
  );
}
