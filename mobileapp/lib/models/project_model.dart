import 'package:flutter/foundation.dart';
import 'user_model.dart';

class ProjectModel {
  final int id;
  final String name;
  final String description;
  final List<UserModel> members;
  final int? ownerId;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    this.members = const [],
    this.ownerId,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];
    final members = rawMembers is List
        ? rawMembers
              .map((m) => UserModel.fromJson(m as Map<String, dynamic>))
              .toList()
        : <UserModel>[];

    // Backend może zwracać owner jako URL (".../api/users/28/"), int lub null.
    final ownerRaw = json['owner'] ?? json['owner_id'] ?? json['created_by'];
    final ownerId = _extractId(ownerRaw);
    debugPrint(
      '[PROJECT_MODEL] id=${json['id']} | '
      'owner=${json['owner']} | owner_id=${json['owner_id']} | '
      'created_by=${json['created_by']} | ownerId parsed=$ownerId',
    );

    return ProjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      members: members,
      ownerId: ownerId,
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

  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}
