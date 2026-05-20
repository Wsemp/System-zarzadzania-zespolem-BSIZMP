class InvitationModel {
  final int id;
  final int? projectId;
  final String projectName;
  final int? inviteeId;
  final String inviteeUsername;
  final int? invitedById;
  final String invitedByUsername;
  final String status; // pending, accepted, rejected
  final String createdAt;

  const InvitationModel({
    required this.id,
    this.projectId,
    required this.projectName,
    this.inviteeId,
    required this.inviteeUsername,
    this.invitedById,
    required this.invitedByUsername,
    required this.status,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    final projectRaw = json['project'];
    final inviteeRaw = json['invitee'];
    final inviterRaw = json['invited_by'] ?? json['inviter'];

    return InvitationModel(
      id: json['id'] as int,
      projectId: _extractId(projectRaw),
      projectName: _extractName(projectRaw, json['project_name']) ?? 'Projekt',
      inviteeId: _extractId(inviteeRaw),
      inviteeUsername:
          _extractUsername(inviteeRaw, json['invitee_username']) ?? '',
      invitedById: _extractId(inviterRaw),
      invitedByUsername:
          _extractUsername(inviterRaw, json['invited_by_username']) ??
          _extractUsername(inviterRaw, json['inviter_username']) ??
          '',
      status: json['status'] as String? ?? 'pending',
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

  static String? _extractName(dynamic value, dynamic fallback) {
    if (value is Map) return value['name'] as String?;
    if (fallback is String) return fallback;
    return null;
  }

  static String? _extractUsername(dynamic value, dynamic fallback) {
    if (value is Map) return value['username'] as String?;
    if (fallback is String) return fallback;
    return null;
  }
}
