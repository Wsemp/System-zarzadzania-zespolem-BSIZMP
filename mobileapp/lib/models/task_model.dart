enum TaskStatus { todo, inProgress, done }

extension TaskStatusExt on TaskStatus {
  String get value {
    switch (this) {
      case TaskStatus.todo:
        return 'todo';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.done:
        return 'done';
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  static TaskStatus fromString(String? value) {
    switch (value) {
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
  // TODO: potwierdź nazwę pola z backendem – może być 'project_id'
  final int? project;
  final List<int> tagIds;
  final String? dueDate;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.assignedTo,
    this.project,
    required this.tagIds,
    this.dueDate,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    status: TaskStatusExt.fromString(json['status'] as String?),
    assignedTo: json['assigned_to'] as int?,
    project: json['project'] as int?,
    tagIds:
        (json['tag_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ??
        [],
    dueDate: json['due_date'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'status': status.value,
    'assigned_to': assignedTo,
    'project': project,
    'tag_ids': tagIds,
    'due_date': dueDate,
  };

  TaskModel copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    int? assignedTo,
    int? project,
    List<int>? tagIds,
    String? dueDate,
  }) => TaskModel(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    assignedTo: assignedTo ?? this.assignedTo,
    project: project ?? this.project,
    tagIds: tagIds ?? this.tagIds,
    dueDate: dueDate ?? this.dueDate,
  );
}
