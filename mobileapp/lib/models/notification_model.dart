class NotificationModel {
  final int id;
  final String message;
  final String? type;
  final bool isRead;
  final int? taskId;
  final String? taskTitle;
  final int? projectId;
  final String? projectName;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.message,
    this.type,
    required this.isRead,
    this.taskId,
    this.taskTitle,
    this.projectId,
    this.projectName,
    required this.createdAt,
  });

  String get displayMessage {
    final t = (type ?? '').toLowerCase();

    if (t.contains('task_assigned') || t.contains('assigned')) {
      return taskTitle != null
          ? 'Przypisano Ci nowe zadanie: $taskTitle'
          : 'Przypisano Ci nowe zadanie';
    }
    if (t.contains('task_status') || t.contains('status_changed')) {
      return taskTitle != null
          ? 'Zmieniono status zadania: $taskTitle'
          : 'Zmieniono status zadania';
    }
    if (t.contains('project_closed') || t.contains('closed')) {
      return projectName != null
          ? 'Projekt "$projectName" został zamknięty'
          : 'Projekt został zamknięty';
    }
    if (t.contains('project_started') ||
        t.contains('project_active') ||
        t.contains('started')) {
      return projectName != null
          ? 'Projekt "$projectName" został rozpoczęty'
          : 'Projekt został rozpoczęty';
    }
    if (t.contains('joined') || t.contains('member')) {
      return projectName != null
          ? 'Dołączyłeś do projektu "$projectName"'
          : 'Dołączyłeś do projektu';
    }
    if (t.contains('invitation') ||
        t.contains('invited') ||
        t.contains('invite')) {
      return projectName != null
          ? 'Zaproszono Cię do projektu "$projectName"'
          : 'Masz nowe zaproszenie do projektu';
    }

    return _translateByContent(message);
  }

  static String _translateByContent(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('assigned') && lower.contains('task')) {
      return 'Przypisano Ci nowe zadanie';
    }
    if (lower.contains('status') && lower.contains('changed')) {
      return 'Zmieniono status zadania';
    }
    if (lower.contains('closed') || lower.contains('completed')) {
      return 'Projekt został zamknięty';
    }
    if (lower.contains('started') || lower.contains('active')) {
      return 'Projekt został rozpoczęty';
    }
    if (lower.contains('joined') || lower.contains('member added')) {
      return 'Dołączyłeś do projektu';
    }
    if (lower.contains('invitation') || lower.contains('invited')) {
      return 'Masz nowe zaproszenie do projektu';
    }
    return msg;
  }

  bool get isRelevant {
    final t = (type ?? '').toLowerCase();
    final lower = message.toLowerCase();

    if (t.isNotEmpty) {
      return t.contains('task') ||
          t.contains('project') ||
          t.contains('invitation') ||
          t.contains('joined') ||
          t.contains('assigned') ||
          t.contains('status') ||
          t.contains('member');
    }

    return lower.contains('task') ||
        lower.contains('project') ||
        lower.contains('invitation') ||
        lower.contains('assigned') ||
        lower.contains('status') ||
        lower.contains('closed') ||
        lower.contains('started') ||
        lower.contains('joined');
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final taskRaw = json['task'];
    final projectRaw = json['project'];

    return NotificationModel(
      id: json['id'] as int,
      message:
          json['message'] as String? ??
          json['content'] as String? ??
          'Nowe powiadomienie',
      type:
          json['notification_type'] as String? ??
          json['type'] as String? ??
          json['event_type'] as String?,
      isRead: json['is_read'] as bool? ?? json['read'] as bool? ?? false,
      taskId: _extractId(taskRaw),
      taskTitle: taskRaw is Map ? taskRaw['title'] as String? : null,
      projectId: _extractId(projectRaw),
      projectName: projectRaw is Map ? projectRaw['name'] as String? : null,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  static int? _extractId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is Map) return value['id'] as int?;
    if (value is String) {
      final parts = value.split('/').where((s) => s.isNotEmpty).toList();
      return parts.isNotEmpty ? int.tryParse(parts.last) : null;
    }
    return null;
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id,
    message: message,
    type: type,
    isRead: isRead ?? this.isRead,
    taskId: taskId,
    taskTitle: taskTitle,
    projectId: projectId,
    projectName: projectName,
    createdAt: createdAt,
  );
}
