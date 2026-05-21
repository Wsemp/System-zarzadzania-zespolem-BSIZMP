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

// ─── Priority ────────────────────────────────────────────────────────────────

enum TaskPriority { low, medium, high }

extension TaskPriorityExt on TaskPriority {
  String get value {
    switch (this) {
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
    }
  }

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Niski';
      case TaskPriority.medium:
        return 'Średni';
      case TaskPriority.high:
        return 'Wysoki';
    }
  }

  static TaskPriority fromString(String? value) {
    switch (value) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      default:
        return TaskPriority.medium;
    }
  }
}

// ─── Area ────────────────────────────────────────────────────────────────────

enum TaskArea { backend, frontend, uiUx, testing }

extension TaskAreaExt on TaskArea {
  String get value {
    switch (this) {
      case TaskArea.backend:
        return 'backend';
      case TaskArea.frontend:
        return 'frontend';
      case TaskArea.uiUx:
        return 'ui_ux';
      case TaskArea.testing:
        return 'testing';
    }
  }

  String get label {
    switch (this) {
      case TaskArea.backend:
        return 'Backend';
      case TaskArea.frontend:
        return 'Frontend';
      case TaskArea.uiUx:
        return 'UI/UX';
      case TaskArea.testing:
        return 'Testowanie';
    }
  }

  static TaskArea? fromString(String? value) {
    switch (value) {
      case 'backend':
        return TaskArea.backend;
      case 'frontend':
        return TaskArea.frontend;
      case 'ui_ux':
        return TaskArea.uiUx;
      case 'testing':
        return TaskArea.testing;
      default:
        return null;
    }
  }
}

// ─── TaskModel ────────────────────────────────────────────────────────────────

class TaskModel {
  final int id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final TaskArea? area;
  final int? assignedTo;
  final String? assignedToUsername;
  final int? reportedBy;
  final String? reportedByUsername;
  final bool anonymousReporter;
  final int? project;
  final List<int> tagIds;
  final String? dueDate;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.priority = TaskPriority.medium,
    this.area,
    this.assignedTo,
    this.assignedToUsername,
    this.reportedBy,
    this.reportedByUsername,
    this.anonymousReporter = false,
    this.project,
    required this.tagIds,
    this.dueDate,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final assignedRaw = json['assigned_to'];
    final projectRaw = json['project'];
    final tagsRaw = json['tag_ids'] ?? json['tags'] ?? const [];
    final reporterRaw = json['reported_by'];

    return TaskModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: TaskStatusExt.fromString(json['status'] as String?),
      priority: TaskPriorityExt.fromString(json['priority'] as String?),
      area: TaskAreaExt.fromString(json['area'] as String?),
      assignedTo: _extractId(assignedRaw),
      assignedToUsername: assignedRaw is Map
          ? assignedRaw['username'] as String?
          : null,
      reportedBy: _extractId(reporterRaw),
      reportedByUsername: json['reported_by_username'] as String?,
      anonymousReporter: json['anonymous_reporter'] as bool? ?? false,
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
    TaskPriority? priority,
    TaskArea? area,
    int? assignedTo,
    String? assignedToUsername,
    int? reportedBy,
    String? reportedByUsername,
    bool? anonymousReporter,
    int? project,
    List<int>? tagIds,
    String? dueDate,
    bool clearAssignee = false,
    bool clearDueDate = false,
    bool clearArea = false,
  }) => TaskModel(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    area: clearArea ? null : (area ?? this.area),
    assignedTo: clearAssignee ? null : (assignedTo ?? this.assignedTo),
    assignedToUsername: clearAssignee
        ? null
        : (assignedToUsername ?? this.assignedToUsername),
    reportedBy: reportedBy ?? this.reportedBy,
    reportedByUsername: reportedByUsername ?? this.reportedByUsername,
    anonymousReporter: anonymousReporter ?? this.anonymousReporter,
    project: project ?? this.project,
    tagIds: tagIds ?? this.tagIds,
    dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
  );
}
