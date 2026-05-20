class NotificationModel {
  final int id;
  final String message;
  final bool isRead;
  final int? taskId;
  final String? taskTitle;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.message,
    required this.isRead,
    this.taskId,
    this.taskTitle,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final taskRaw = json['task'];

    return NotificationModel(
      id: json['id'] as int,
      message:
          json['message'] as String? ??
          json['content'] as String? ??
          'Nowe powiadomienie',
      isRead: json['is_read'] as bool? ?? json['read'] as bool? ?? false,
      taskId: _extractId(taskRaw),
      taskTitle: taskRaw is Map ? taskRaw['title'] as String? : null,
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
    isRead: isRead ?? this.isRead,
    taskId: taskId,
    taskTitle: taskTitle,
    createdAt: createdAt,
  );
}
