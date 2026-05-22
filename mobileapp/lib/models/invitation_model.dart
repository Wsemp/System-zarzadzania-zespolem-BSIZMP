class InvitationModel {
  final int id;
  final int? projectId;
  final String projectName;
  final String inviteeEmail;
  final int? invitedById;
  final String invitedByUsername;
  final String message;
  final String? expiresAt;
  final bool accepted;
  final String createdAt;

  const InvitationModel({
    required this.id,
    this.projectId,
    required this.projectName,
    required this.inviteeEmail,
    this.invitedById,
    required this.invitedByUsername,
    required this.message,
    this.expiresAt,
    required this.accepted,
    required this.createdAt,
  });

  bool get isPending => !accepted;
  String get status => accepted ? 'accepted' : 'pending';

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    final acceptedBool = json['accepted'] as bool? ?? false;
    final projectRaw = json['project'];
    final inviterRaw = json['inviter'];

    return InvitationModel(
      id: json['id'] as int,
      projectId: _extractId(projectRaw),
      projectName: json['project_name'] as String? ?? 'Projekt',
      inviteeEmail: json['email'] as String? ?? '',
      invitedById: _extractId(inviterRaw),
      invitedByUsername: json['inviter_username'] as String? ?? '',
      message: json['message'] as String? ?? '',
      expiresAt: json['expires_at'] as String?,
      accepted: acceptedBool,
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
}
